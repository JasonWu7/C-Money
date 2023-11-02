//
//  RecordTableViewController.swift
//  C-Money
//
//  Created by Dongzheng Wu on 25/4/2023.
//

import UIKit

class RecordTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {
    
    //  Data change methods for firebase.
    func onProgressChange(change: DatabaseChange, progress: [Progress]) {
        //  Not required in this screen.
    }
    
    func onSavingChange(change: DatabaseChange, saving: [Saving]) {
        //  Not required in this screen.
    }
    
    func onRecordChange(change: DatabaseChange, records: [Record]) {
        allRecords = records
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    var listenerType = ListenerType.record
    
    let SECTION_RECORD = 0
    let SECTION_TOTAL = 1
    
    let CELL_RECORD = "recordCell"
    let CELL_TOTAL = "totalCell"
    
    var allRecords: [Record] = []
    var filteredRecrods: [Record] = []
    
    var sectionsNumber = 2
    
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        filteredRecrods = allRecords
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search All Records"
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        if searchText.count > 0 {
            filteredRecrods = allRecords.filter({ (record: Record) -> Bool in
                return (record.note?.lowercased().contains(searchText) ?? false)
            })
        }
        else {
            filteredRecrods = allRecords
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsNumber
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_RECORD {
            return filteredRecrods.count
        }
        else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_RECORD {
            let recordCell = tableView.dequeueReusableCell(withIdentifier: CELL_RECORD, for: indexPath) as! RecordTableViewCell
            recordCell.recordCategoryLabel?.text = filteredRecrods[indexPath.row].category
            recordCell.amountLabel?.text = "$ \(filteredRecrods[indexPath.row].amount!)"
            recordCell.backgroundColor = ThemeController.shared.cardBackgroundColor
            return recordCell
        }
        else {
            let totalCell = tableView.dequeueReusableCell(withIdentifier: CELL_TOTAL, for: indexPath) as! RecordCountTableViewCell
            totalCell.totalLabel?.text = "\(filteredRecrods.count) records in the database"
            totalCell.backgroundColor = ThemeController.shared.cardBackgroundColor
            return totalCell
        }
    }
    
    //  Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == SECTION_RECORD {
            return true
        }
        else{
            return false
        }
    }
    
    // MARK: - Navigation

    //  In a storyboard-based application, you will often want to do a little preparation before navigation.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the selected object to the new view controller.
        if segue.identifier == "recordDetailsSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as! RecordDetailsViewController
                destination.record = filteredRecrods[indexPath.row]
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
        //  Theme configuration.
        self.view.backgroundColor = ThemeController.shared.backgroundColor
        self.navigationController?.navigationBar.tintColor = ThemeController.shared.tintColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
}
