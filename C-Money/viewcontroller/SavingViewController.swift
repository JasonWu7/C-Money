//
//  SavingViewController.swift
//  C-Money
//
//  Created by Dongzheng Wu on 18/4/2023.
//

import UIKit
import SwiftUI
import UserNotifications

class SavingViewController: UIViewController, DatabaseListener, UITableViewDelegate, UITableViewDataSource {
    
    //  Data change methods for firebase.
    func onRecordChange(change: DatabaseChange, records: [Record]) {
        //  Not required in this screen.
    }
    
    func onProgressChange(change: DatabaseChange, progress: [Progress]) {
        currentProgress = progress
        progressTableView.reloadData()
    }
    
    func onSavingChange(change: DatabaseChange, saving: [Saving]) {
        currentSaving = saving
        
        //  Configure the saving methods label and manual input components.
        if currentSaving.count == 1 {
            savingMethodLabel.text = savingMethods[currentSaving[0].method!]
            if savingMethodLabel.text == "Manual" {
                savingAmountField.isHidden = false
                addSavingAmountButton.isHidden = false
            }
            else{
                savingAmountField.isHidden = true
                addSavingAmountButton.isHidden = true
            }
            if Double(currentSaving[0].currentAmount!)/Double(currentSaving[0].amount!) >= 0.9 {
                triggerNotification()
            }
            updateSaving()
        }
        if currentSaving.count == 0 {
            savingMethodLabel.text = "No saving plan right now"
            addSavingAmountButton.isHidden = true
            savingAmountField.isHidden = true
            updateSaving()
        }
    }
    
    var listenerType = ListenerType.all

    @IBOutlet weak var addSavingAmountButton: UIButton!
    @IBOutlet weak var savingAmountField: UITextField!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var progressTableView: UITableView!
    @IBOutlet weak var savingMethodLabel: UILabel!
    
    var savingMethods = ["Expenditure", "Income", "Expenditure and Income", "Manual"]
    
    weak var databaseController: DatabaseProtocol?
    
    var currentSaving: [Saving] = []
    var currentProgress = [Progress]()
    
    var savingChartController: UIHostingController<ContentView>?
    
    var chartView = UIView()
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.cornerRadius = 10
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        //  Tableview configuration.
        progressTableView.delegate = self
        progressTableView.dataSource = self
        progressTableView.allowsSelection = false
                
        //  Request notification autorizatoin.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]){
            (granted, error) in
            if !granted{
                print("Permission was not granted")
                return
            }
        }
        
        //  Initialise the progress chart.
        let progressController = UIHostingController(rootView: ContentView(currentAmount: 0.0))
        
        guard let contentView = progressController.view else{
            return
        }
        view.addSubview(contentView)
        addChild(progressController)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor,
                        constant: 40.0),
            
            contentView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor,
                        constant: -40.0),
            contentView.topAnchor.constraint(equalTo:
                                                backgroundView.safeAreaLayoutGuide.topAnchor, constant: 40.0)
            ])
        
        savingChartController = progressController
        
        chartView = contentView
    }
    
    func triggerNotification() {
        //  Not triggering notification if user turn off the setting.
        if userDefaults.bool(forKey: "notificationOff") == true || currentSaving[0].notification == false {
            return
        }
        
        //  Create notification content.
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "This is test notification"
        notificationContent.subtitle = "C-MONEY"
        notificationContent.body = "You are close to your target"
        
        //  Create notification trigger.
        let timeInterval = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent , trigger: timeInterval)
        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                print(String(describing: error))
            }
        }
        
        //  Configure the recurring date.
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        
        dateComponents.weekday = 6      // Friday.
        dateComponents.hour = 19        // 7 pm.
        
        //  Create the trigger.
        _ = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    }

    @IBAction func deleteSaving(_ sender: Any) {
        
        if !currentSaving.isEmpty {
            databaseController?.deleteSaving(saving: currentSaving[0])
            currentSaving = [Saving]()
            for progress in currentProgress {
                databaseController?.deleteProgress(progress: progress)
            }
            currentProgress = [Progress]()
            displayMessage(title: "Success", message: "Your saving has been deleted")
        }
        else{
            displayMessage(title: "Fails", message: "No saving plan right now")
        }
    }
    
    func updateSaving() {
        if currentSaving.isEmpty {
            //  Initialise chart.
            savingChartController?.rootView.updateChartData(amount: 0.0)
            return
        }
        
        savingChartController?.rootView.updateChartData(amount: Double(currentSaving[0].currentAmount!)/Double(currentSaving[0].amount!))
    }
    
    @IBAction func addSavingAmount(_ sender: Any) {
        let amountInput: Int? = Int(savingAmountField.text!)
        if amountInput == nil{
            displayMessage(title: "Fails", message: "Please Enter Amount")
            return
        }
        let newAmount = currentSaving[0].currentAmount! + amountInput!
        currentSaving[0].currentAmount = newAmount
        databaseController?.savingRef?.document(currentSaving[0].id!).updateData(["currentAmount": newAmount])
        let progress = Progress()
        progress.amount = amountInput
        progress.date = Date.now
        databaseController?.addProgressIntoProgresses(progress: progress)
        updateSaving()
    }
    
    //  Progress table methods.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2        //  Fixed number of section.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return currentProgress.count
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let progressCell = tableView.dequeueReusableCell(withIdentifier: "progressCell", for: indexPath)
            let progress = currentProgress[indexPath.row]
            progressCell.textLabel?.text = "\(progress.getDateString())      $\(progress.amount!)"
            return progressCell
        }
        else{
            let totalCell = tableView.dequeueReusableCell(withIdentifier: "totalCell", for: indexPath)
            totalCell.textLabel?.text = "\(currentProgress.count) progress records in the database"
            return totalCell
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
        //  Theme configuration.
        self.view.backgroundColor = ThemeController.shared.backgroundColor
        backgroundView.backgroundColor = ThemeController.shared.cardBackgroundColor
        progressTableView.backgroundColor = ThemeController.shared.cardBackgroundColor
        chartView.backgroundColor = ThemeController.shared.cardBackgroundColor
        chartView.tintColor = ThemeController.shared.tintColor
        savingChartController?.rootView.updateChartColor()
        savingMethodLabel.textColor = ThemeController.shared.textColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
}
