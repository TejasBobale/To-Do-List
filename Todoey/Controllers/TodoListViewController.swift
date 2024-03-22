//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    let realm = try! Realm()
    var todoItems: Results<Item>?
    var selectedCategory: Category?{
        didSet{
            loadItems()
        }
    }
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(dataFilePath)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color{
            title = selectedCategory?.name ?? "Items"
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist")}
            if let  navBarColor = UIColor(hexString: colorHex){
                navBar.backgroundColor = navBarColor
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                searchBar.barTintColor = UIColor(hexString: colorHex)
            }
        }
    }

    
    // MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done == true ? .checkmark : .none
            if let color = UIColor(hexString: selectedCategory?.color ?? "#3498db")?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count)){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        }
        else{
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row]{
            do {
                try realm.write{
                    item.done = !item.done
                }
            } catch {
                print("ERROR \(error)")
            }
        }
        tableView.reloadData()
//        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // MARK: - Add New Item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Task", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Task", style: .default){(action) in
            if let currentCategory = self.selectedCategory{
                do {
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.done = false
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("ERROR \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField{ (alertTextField) in
            alertTextField.placeholder = "Create new task"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Model Manipulation Method
    
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    //MARK: - Delete data from swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row]{
            do {
                try realm.write{
                    realm.delete(item)
                }
            } catch {
                print("ERROR \(error)")
            }
        }
    }
}

extension TodoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
