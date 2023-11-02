//
//  AddSavingViewController.swift
//  C-Money
//
//  Created by Dongzheng Wu on 21/4/2023.
//

import UIKit

class AddSavingViewController: UIViewController {
    
    var currentSaving = Saving()
    weak var databaseController: DatabaseProtocol?

    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var noteTextField: UITextView!
    @IBOutlet weak var targetAmountTextField: UITextField!
    @IBOutlet weak var savingMethodSegmented: UISegmentedControl!
    @IBOutlet weak var typeSegmented: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        self.dismissKeyboardWhenTap()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }

    //  Validating the user inputs.
    func inputValidation() -> Bool {
        guard let note = noteTextField.text, let amount = targetAmountTextField.text else{
            return false
        }
        var errorMsg = ""
        if note.isEmpty {
            errorMsg += "Must provide a valid note\n"
        }
        if amount.isEmpty {
            errorMsg += "Must provide a valid amount\n"
        }
        if startDate.date > endDate.date || endDate.date < Date.now{
            errorMsg += "Must provide a valid date"
        }
        if errorMsg.isEmpty {
            return true
        }
        displayMessage(title: "Create Fails", message: errorMsg)
        return false
    }
    
    @IBAction func typeSegmentedChanged(_ sender: Any) {
        if typeSegmented.selectedSegmentIndex == 0{
            typeSegmented.selectedSegmentIndex = 1
            navigationController?.popViewController(animated: false)
        }
    }
    
    @IBAction func createSaving(_ sender: Any) {
        if inputValidation() {
            
            //  Add saving to database.
            let saving = Saving()
            let method = Method(rawValue: Int(savingMethodSegmented.selectedSegmentIndex))
            saving.note = noteTextField.text
            saving.amount = Int(targetAmountTextField.text!)
            saving.currentAmount = 0
            saving.start_date = startDate.date
            saving.end_date = endDate.date
            saving.savingmethod = method!
            
            let result = databaseController?.addSavingIntoSavings(saving: saving)
            if result! {
                displayMessage(title: "Success", message: "New saving is added.")
            }
            else {
                displayMessage(title: "Fails", message: "Only One saving can exist at one time.")
            }
        }
    }
    
    @IBAction func clearChanges(_ sender: Any) {
        targetAmountTextField.text = ""
        noteTextField.text = ""
        savingMethodSegmented.selectedSegmentIndex = 0
        notificationSwitch.setOn(true, animated: true)
        startDate.date = Date.now
        endDate.date = Date.now
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //  Theme configuration.
        self.view.backgroundColor = ThemeController.shared.backgroundColor
    }
}
