//
//  CustomiseCategoryViewController.swift
//  C-Money
//
//  Created by Dongzheng Wu on 12/5/2023.
//

import UIKit

class CustomiseCategoryViewController: UIViewController, CoredataListener, UITableViewDelegate, UITableViewDataSource {
    
    //  Coredata change methods.
    func onCategoryChange(change: CoredataChange, categories: [Category]) {
        currentCategories = categories
        categoryTableView.reloadData()
    }
    
    var coredataListenerType = CoredataListenerType.category
    weak var coredataController: CoredataProtocol?

    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var categoryNameTextField: UITextField!
    
    var selectedCategory = -1       //  By default the category is not selected.

    var currentCategories = [Category]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        coredataController = appDelegate?.coredataController
        
        //  Category tableview configurations.
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.allowsSelection = true
        categoryTableView.isUserInteractionEnabled = true
    }
    
    //  Tableview methods.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryCell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        categoryCell.textLabel?.text = currentCategories[indexPath.row].categoryName
        
        return categoryCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //  "Income" category is not allowed to be deleted.
        if indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        else{
            selectedCategory = indexPath.row
        }
    }
    
    @IBAction func createNewCategory(_ sender: Any) {
        guard let name = categoryNameTextField.text else{
            displayMessage(title: "Fails", message: "Please enter the new category name")
            return
        }
        //  Check if the category is already exist.
        for category in currentCategories {
            if category.categoryName == name{
                displayMessage(title: "Fails", message: "Duplicate category name exist")
                return
            }
        }
        coredataController?.addCategory(categoryName: name)
        displayMessage(title: "Success", message: "New category has added")
    }
    
    
    @IBAction func removeCategory(_ sender: Any) {
        if selectedCategory == -1 {
            displayMessage(title: "Fails", message: "Please select category first")
        }
        else{
            coredataController?.deleteCategory(category: currentCategories[selectedCategory])
            displayMessage(title: "Success", message: "Category has been deleted")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        coredataController?.addListener(listener: self)
        
        //  Theme configuration.
        self.view.backgroundColor = ThemeController.shared.backgroundColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        coredataController?.removeListener(listener: self)
    }
}
