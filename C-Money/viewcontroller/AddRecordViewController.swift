//
//  AddViewController.swift
//  C-Money
//
//  Created by Dongzheng Wu on 18/4/2023.
//

import UIKit
import MapKit

class AddRecordViewController: UIViewController, DatabaseListener, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, CoredataListener {
    //  Coredata change methods.
    func onCategoryChange(change: CoredataChange, categories: [Category]) {
        currentCategories = categories
        categoryTableView.reloadData()
    }
    
    //  Data change methods for firebase.
    func onProgressChange(change: DatabaseChange, progress: [Progress]) {
        //  Not required in this screen.
    }
    
    func onRecordChange(change: DatabaseChange, records: [Record]) {
        //  Not required in this screen.
    }
    
    func onSavingChange(change: DatabaseChange, saving: [Saving]) {
        if !saving.isEmpty {
            currentSaving = saving[0]
        }
    }
    
    @IBOutlet weak var searchLocationButton: UIButton!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var typeSegmented: UISegmentedControl!
    @IBOutlet weak var customiseCategory: UIButton!
    
    var hideDatePicker: Bool = true
    
    var coredataListenerType = CoredataListenerType.category
    weak var coredataController: CoredataProtocol?
    
    var listenerType = ListenerType.saving
    weak var databaseController: DatabaseProtocol?
    
    var currentCategories = [Category]()
    var selectedCategory = -1
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var currentAddress: String?
    
    var currentSaving: Saving?
    
    //  API url.
    let REQUEST_STRING = "https://dev.virtualearth.net/REST/v1/locationrecog/"
    let TRAIL_REQUEST_STRING = "?key=AkpS6cQgypLeDPfEnPaeeY3ukVtQ6u0jv1uc5jErT9XTWlAL6gXywIDelJE2N7Mn&includeEntityTypes=address&output=json"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customiseCategory.titleLabel?.textAlignment = .center
        self.dismissKeyboardWhenTap()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        coredataController = appDelegate?.coredataController
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        categoryTableView.allowsSelection = true
        categoryTableView.isUserInteractionEnabled = true
        
        //  Resolved tap gesture conflicts in view to allow using single tap to select the content in category table view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
                
        let authorisationStatus = locationManager.authorizationStatus
        
        //  Request location permission and hide the search button if it is not granted.
        if authorisationStatus != .authorizedWhenInUse {
            searchLocationButton.isHidden = true
            
            if authorisationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    @IBAction func typeSegmentedChanged(_ sender: Any) {
        if typeSegmented.selectedSegmentIndex == 1 {
            typeSegmented.selectedSegmentIndex = 0
            self.performSegue(withIdentifier: "addSavingSegue", sender: self)
        }
    }
    
    @IBAction func createRecord(_ sender: Any) {
        if inputValidation() {
            
            //  Add record to database.
            var record = Record()
            record.category = currentCategories[selectedCategory].categoryName
            record.amount = Int(amountTextField.text!)
            record.date_time = datePicker.date
            record.note = noteTextField.text
            record.location = locationTextField.text
            let result = databaseController?.addRecordIntoRecords(record: record)
            if result! {
                displayMessage(title: "Success", message: "New record is added.")
                if currentSaving != nil {
                    updateSavingProgress(record: record)
                }
                let authorisationStatus = locationManager.authorizationStatus
                if authorisationStatus == .authorizedAlways || authorisationStatus == .authorizedWhenInUse {
                    searchLocationButton.isHidden = false
                }
                clearChanges(self)
            }
            else {
                displayMessage(title: "Fails", message: "Something went wrong when adding record")
            }
        }
    }
    
    @IBAction func searchLocation(_ sender: Any) {
        //  Use the location of user to requst the address through API.
        let lat = "\(String(describing: currentLocation!.latitude))"
        let lng = "\(String(describing: currentLocation!.longitude))"
        Task {
            await requestAddress(lat, lng)
        }
    }
    
    @IBAction func clearChanges(_ sender: Any) {
        amountTextField.text = ""
        noteTextField.text = ""
        locationTextField.text = ""
        datePicker.date = Date.now
        let authorisationStatus = locationManager.authorizationStatus
        if authorisationStatus == .authorizedAlways || authorisationStatus == .authorizedWhenInUse {
            searchLocationButton.isHidden = false
        }
    }
    
    func inputValidation() -> Bool {
        guard let location = locationTextField.text, let note = noteTextField.text, let amount = amountTextField.text else{
            return false
        }
        var errorMsg = ""
        if location.isEmpty {
            errorMsg += "Must provide a valid location\n"
        }
        if note.isEmpty {
            errorMsg += "Must provide a valid note\n"
        }
        if amount.isEmpty {
            errorMsg += "Must provide a valid amount\n"
        }
        if datePicker.date > Date.now {
            errorMsg += "Must provide a valid date\n"
        }
        if selectedCategory < 0 {
            errorMsg += "Must select or customize a category"
        }
        if errorMsg.isEmpty {
            return true
        }
        displayMessage(title: "Create Fails", message: errorMsg)
        return false
    }
    
    func updateSavingProgress(record: Record) {
        guard let saving = currentSaving else {
            return
        }
        let progress = Progress()
        var updateProgress = false
        var negativeUpdateProgress = false
        if saving.savingmethod == Method.save_from_expenditure && record.category != "Income" {
            saving.currentAmount! += record.amount!
            updateProgress = true
        }
        else if saving.savingmethod == Method.save_from_income && record.category == "Income" {
            saving.currentAmount! += record.amount!
            updateProgress = true
        }
        else if saving.savingmethod == Method.save_from_both{
            updateProgress = true
            if record.category == "Income" {
                saving.currentAmount! += record.amount!
            }
            else {
                saving.currentAmount! -= record.amount!
                negativeUpdateProgress = true
            }
        }
        if updateProgress {
            progress.date = record.date_time!
            progress.amount = record.amount!
            if negativeUpdateProgress {
                progress.amount = -record.amount!
            }
            databaseController?.addProgressIntoProgresses(progress: progress)
        }
        databaseController?.savingRef?.document(saving.id!).updateData(["currentAmount": saving.currentAmount])
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //  Configure the placeholder and button if location permission is granted.
        if manager.authorizationStatus == .authorizedWhenInUse {
            searchLocationButton.isHidden = false
            locationTextField.placeholder = "Find your location"
        }
    }
    
    //  Get the user's location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last?.coordinate
    }
    
    //  Make API request.
    func requestAddress(_ lat: String, _ lng: String) async {
        guard let queryString = (lat+","+lng+TRAIL_REQUEST_STRING).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("query string cannot be encoded")
            return
        }
        
        guard let requestURL = URL(string: REQUEST_STRING + queryString) else {
            print("Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("status not equal to 200")
                return
            }
            let decoder = JSONDecoder()
            let json = try! decoder.decode(GeoData.self, from: data)
            locationTextField.text = json.resourceSets[0].resources[0].addressOfLocation[0].formattedAddress
            searchLocationButton.isHidden = true
        }
        catch let error {
            print(error)
        }
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
        locationManager.startUpdatingLocation()
        databaseController?.addListener(listener: self)
        coredataController?.addListener(listener: self)
        
        //  Theme configuration.
        self.view.backgroundColor = ThemeController.shared.backgroundColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
        databaseController?.addListener(listener: self)
        coredataController?.removeListener(listener: self)
    }
}
