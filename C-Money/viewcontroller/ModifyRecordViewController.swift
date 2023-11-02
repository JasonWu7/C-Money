//
//  ModifyRecordViewController.swift
//  C-Money
//
//  Created by Dongzheng Wu on 16/5/2023.
//

import UIKit

class ModifyRecordViewController: UIViewController, CoredataListener, UITableViewDelegate, UITableViewDataSource {
    
    //  Coredata change method.
    func onCategoryChange(change: CoredataChange, categories: [Category]) {
        currentCategories = categories
        categoryTableView.reloadData()
        if record != nil {
            for (i, e) in currentCategories.enumerated() {
                if e.categoryName == record!.category {
                    let indexPath = IndexPath(row: i, section: 0)
                    selectedCategory = i
                    categoryTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                }
            }
        }
    }
    
    var coredataListenerType = CoredataListenerType.category
    weak var coredataController: CoredataProtocol?
    weak var databaseController: DatabaseProtocol?
    var record: Record?
    var currentCategories = [Category]()
    var selectedCategory = -1       //  By default the category is not selected.

    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var noteTextArea: UITextView!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var amountTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        coredataController = appDelegate?.coredataController
        databaseController = appDelegate?.databaseController
        
        //  Category tableview configurations.
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.allowsSelection = true
        categoryTableView.isUserInteractionEnabled = true
        
        //  Fill the components with record information.
        if record != nil{
            locationTextField.text = record!.location
            noteTextArea.text = record!.note
            dateTimePicker.date = record!.date_time!
            amountTextField.text = "\(record!.amount!)"
        }
    }
    
    @IBAction func modifyRecord(_ sender: Any) {
        let amountInput: Int? = Int(amountTextField.text!)
        record?.amount = amountInput
        record?.location = locationTextField.text
        
        //  A possible situation that the customised category is used in this record has been removed, doing so avoid index overflow.
        if selectedCategory != -1 {
            record?.category = currentCategories[selectedCategory].categoryName
        }
        
        record?.date_time = dateTimePicker.date
        record?.note = noteTextArea.text
        databaseController?.recordRef?.document((record?.id)!).updateData(["amount": record?.amount, "category": record?.category, "date_time": record?.date_time, "location": record?.location, "note": record?.note])
        displayMessage(title: "Success", message: "Record has been modified")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! RecordDetailsViewController
        destination.record = self.record
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
        selectedCategory = indexPath.row
    }
    
    override func viewWillAppear(_ animated: Bool) {
        coredataController?.addListener(listener: self)
        
        // Theme configuration.
        self.view.backgroundColor = ThemeController.shared.backgroundColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        coredataController?.removeListener(listener: self)
    }
}
