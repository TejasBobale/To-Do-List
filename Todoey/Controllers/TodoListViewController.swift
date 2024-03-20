//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    
    let realm = try! Realm()
    var todoItems: Results<Item>?
    var selectedCategory: Category?{
        didSet{
            loadItems()
        }
    }
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(dataFilePath)
    }

    
    // MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done == true ? .checkmark : .none
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
        
//        context.delete(itemArray[indexPath.row])
//        todoItems.remove(at: indexPath.row)
        
        //todoItems[indexPath.row].done = !itemArray[indexPath.row].done
        
//        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
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
    
    func saveItems(){
//        do {
//            try context.save()
//        } catch  {
//            print("ERROR SAVING CONTEXT -> \(error)")
//        }
//
    }
    
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
}

extension TodoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//        
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request, predicate: predicate)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0{
//            loadItems()
//            
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//            }
//            
//        }
    }
}
