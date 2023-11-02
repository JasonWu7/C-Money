//
//  RecordDetailsViewController.swift
//  C-Money
//
//  Created by Dongzheng Wu on 10/5/2023.
//

import UIKit

class RecordDetailsViewController: UIViewController {

    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    
    weak var databaseController: DatabaseProtocol?
    var record: Record?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background style configuring.
        backgroundView.layer.cornerRadius = 10
        
        // Fill the details with record information.
        initializeDetails()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    func initializeDetails() {
        guard let recordData = record else {
            return
        }
        categoryLabel.text = recordData.category
        amountLabel.text = "Amount: $\(recordData.amount!)"
        locationLabel.text = "Location: \(recordData.location!)"
        dateLabel.text = "Date: " + recordData.getDateString()
        notesTextView.text = recordData.note
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modifyRecordSegue" {
            let  destination = segue.destination as! ModifyRecordViewController
            destination.record = self.record
        }
    }
    
    @IBAction func deleteRecord(_ sender: Any) {
        guard let recordData = record else {
            return
        }
        databaseController?.deleteRecord(record: recordData)
        navigationController?.popViewController(animated: false)
        displayMessage(title: "Success", message: "This record has been deleted")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Theme configuration.
        self.view.backgroundColor = ThemeController.shared.backgroundColor
        backgroundView.backgroundColor = ThemeController.shared.cardBackgroundColor
    }
}
