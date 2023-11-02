//
//  HomeViewController.swift
//  C-Money
//
//  Created by Dongzheng Wu on 18/4/2023.
//
//  REFERENCE:
//  https://www.simpleswiftguide.com/how-to-build-a-circular-progress-bar-in-swiftui/
//  Aknowledgement has been made in the aknowledgement section in setting page, appreciate again for the author and creator of corresponding blogs and tools.

import UIKit
import SwiftUI
import Charts
import Photos
import PDFKit

//  Line chart for records.
struct ChartUIView: View {
    var records: [Record]
    var color = ThemeController.shared.tintColor
    var body: some View{
        Chart(records, id: \.self) { recordData in
            LineMark(x: .value("Date", recordData.getDateString()),
                     y: .value("Amount", recordData.amount!))
            .foregroundStyle(Color(uiColor: color))
        }
    }
    
    mutating func updateChartColor() {
        color = ThemeController.shared.tintColor
    }
    
    mutating func updateChartData(recordlist: [Record]) {
        records = recordlist
    }
}

//  Cicular progress chart (progress bar).
struct ContentView: View {
    var currentAmount: Double
    var color = ThemeController.shared.tintColor
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                CircularProgressView(progress: currentAmount, color: color)
                Text("\(currentAmount * 100, specifier: "%.0f")")
                    .font(.largeTitle)
                    .bold()
            }.frame(width: 150, height: 150)
            Spacer()
        }
    }
    
    mutating func updateChartColor() {
        color = ThemeController.shared.tintColor
    }
    
    mutating func updateChartData(amount: Double) {
        currentAmount = amount
    }
}

//  Circular progress chart (background and layout).
struct CircularProgressView: View {
    let progress: Double
    var color: UIColor
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color(color).opacity(0.3),
                    lineWidth: 25
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color(uiColor: color),
                    style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
        }
    }
}

class HomeViewController: UIViewController, DatabaseListener {
    
    //  Data change methods for firebase.
    func onProgressChange(change: DatabaseChange, progress: [Progress]) {
        // Not required in this screen.
    }
    
    func onRecordChange(change: DatabaseChange, records: [Record]) {
        recordList = records
        updateRecordGraph()
    }
    
    func onSavingChange(change: DatabaseChange, saving: [Saving]) {
        savingList = saving
        updateSavingGraph()
    }
    
    @IBOutlet weak var timelineSegmented: UISegmentedControl!
    @IBOutlet weak var remainingDaysTextField: UILabel!
    @IBOutlet weak var currentAmountTextField: UILabel!
    @IBOutlet weak var targetAmountTextField: UILabel!
    @IBOutlet weak var spentDaysTextField: UILabel!
    @IBOutlet weak var endDateTextField: UILabel!
    @IBOutlet weak var downloadChartButton: UIButton!
    @IBOutlet weak var startDateTextField: UILabel!
    @IBOutlet weak var timeIntervalSegmentedControl: UISegmentedControl!
    @IBOutlet weak var savingBackgroundView: UIView!
    @IBOutlet weak var recordBackgroundView: UIView!
    @IBOutlet weak var rightArrowButton: UIButton!
    @IBOutlet weak var leftArrowButton: UIButton!

    var recordChartController: UIHostingController<ChartUIView>?
    var savingChartController: UIHostingController<ContentView>?
    var recordChartView = UIView()
    var savingChartView = UIView()

    var listenerType = ListenerType.all
    
    var savingList: [Saving]?
    var recordList = [Record]()
    
    weak var databaseController: DatabaseProtocol?
    
    var startOfRecord = -2       // The number represent the starting record index in records line chart.
    
    var photoPerimssionStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
    
    let userDefaults = UserDefaults.standard
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        //  Configure the corner radius of background view of charts.
        recordBackgroundView.layer.cornerRadius = 10
        savingBackgroundView.layer.cornerRadius = 10
        
        //  Default method for dismiss keyboard when tap on the area other than textfield.
        self.dismissKeyboardWhenTap()
        
        //  Get the add photo to album permission if it is not determined.
        DispatchQueue.main.async {
            if self.photoPerimssionStatus == .notDetermined{
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { PHAuthorizationStatus in
                    if PHAuthorizationStatus == .authorized{
                        self.photoPerimssionStatus = PHAuthorizationStatus
                    }
                }
            }
        }
        
        //  Initialise the record chart.
        let controller = UIHostingController(rootView: ChartUIView(records: recordList))
        guard let chartView = controller.view else {
            return
        }
        view.addSubview(chartView)
        addChild(controller)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                chartView.leadingAnchor.constraint(equalTo: recordBackgroundView.leadingAnchor,
                        constant: 20.0),
                chartView.trailingAnchor.constraint(equalTo: recordBackgroundView.trailingAnchor,
                        constant: -20.0),
                chartView.topAnchor.constraint(equalTo:
                                                recordBackgroundView.safeAreaLayoutGuide.topAnchor, constant: 50.0),
                chartView.bottomAnchor.constraint(equalTo:
                                                    recordBackgroundView.safeAreaLayoutGuide.bottomAnchor, constant: -30.0)
            ])
        
        recordChartController = controller
        recordChartView = chartView
        
        //  Initialise the saving chart.
        let progressController = UIHostingController(rootView: ContentView(currentAmount: 0.0))
        
        guard let contentView = progressController.view else{
            return
        }
        
        view.addSubview(contentView)
        addChild(progressController)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          
            contentView.trailingAnchor.constraint(equalTo: savingBackgroundView.trailingAnchor,
                        constant: -40.0),
            contentView.topAnchor.constraint(equalTo:
                                                savingBackgroundView.safeAreaLayoutGuide.topAnchor, constant: 50.0),
            contentView.bottomAnchor.constraint(equalTo:
                                                    savingBackgroundView.safeAreaLayoutGuide.bottomAnchor, constant: -20.0)
            ])
        
        //  Initialise labels.
        currentAmountTextField.text = "Current:"
        targetAmountTextField.text = "Target:"
        remainingDaysTextField.text = "Remain:"
        spentDaysTextField.text = "Spent:"
        startDateTextField.text = "Start Date:"
        endDateTextField.text = "End Date"
        
        savingChartController = progressController
        savingChartView = contentView
        
        //  Turn on darkmode if it is activated.
        switchDarkMode()
        
        //  Choose the selected theme.
        switchTheme()
    }
    
    @IBAction func timeIntervalSegmentedChanged(_ sender: Any) {
        startOfRecord = -2      // Initialise the index to avoid inconsistent displaying across different time. intervals.
        updateRecordGraph()
    }
    
    @IBAction func moveLeft(_ sender: Any) {
        startOfRecord -= 1
        updateRecordGraph()
    }
    
    @IBAction func moveRight(_ sender: Any) {
        startOfRecord += 1
        updateRecordGraph()
    }
    
    @IBAction func downLoadCharts(_ sender: Any) {
        //  Hide the buttons from context.
        downloadChartButton.isHidden = true
        timelineSegmented.isHidden = true
        rightArrowButton.isHidden = true
        leftArrowButton.isHidden = true

        //  Begin context.
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)

        //  Draw view in that context.
        self.view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)

        //  Get image.
        let screenImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        if photoPerimssionStatus == .authorized {
            //  Save image to album.
            UIImageWriteToSavedPhotosAlbum(screenImage, nil, nil, nil)
            
            let pdfDocument = PDFDocument()
            
            //  Create a PDF page instance from image.
            let pdfPage = PDFPage(image: screenImage)

            //  Insert the PDF page into document.
            pdfDocument.insert(pdfPage!, at: 0)
            
            //  Save PDF to default path.
            let data = pdfDocument.dataRepresentation()
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let docURL = documentDirectory.appendingPathComponent("CMoney-Charts.pdf")
            try! data?.write(to: docURL)
            
            self.displayMessage(title: "Success", message: "Charts saved to album")
        }
        else {
            self.displayMessage(title: "Fils", message: "Charts not saved as no permission allowed")
        }
        
        //  Display the buttons.
        downloadChartButton.isHidden = false
        timelineSegmented.isHidden = false
        rightArrowButton.isHidden = false
        leftArrowButton.isHidden = false
    }
    
    func updateRecordGraph() {
        if recordList.isEmpty {
            return
        }
        
        //  Append element avoid pointing to the recordList.
        var recordsCopy = [Record]()
        for e in recordList {
            let record = Record()
            record.location = e.location
            record.note = e.note
            record.date_time = e.date_time
            record.amount = e.amount
            record.category = e.category
            record.id = e.id
            recordsCopy.append(record)
        }
        
        //  Sort the records in date order.
        let sortedRecords = recordsCopy.sorted(by: {$0.date_time! < $1.date_time!})
        
        //  Filter the records with category Income.
        var filteredRecords = [Record]()
        for record in sortedRecords {
            if record.category!.compare("Income") != .orderedSame {
                filteredRecords.append(record)
            }
        }
        
        //  Not displaying graph if no expenditure records exist.
        if filteredRecords.isEmpty {
            return
        }
        
        var formattedRecords = [Record]()
        formattedRecords.append(filteredRecords[0])

        //  Group the record on same time period.
        for i in 1..<filteredRecords.count {
            var granularity: Calendar.Component
            if timelineSegmented.selectedSegmentIndex == 0 {
                granularity = .day
            }
            else if timelineSegmented.selectedSegmentIndex == 1 {
                granularity = .weekOfMonth
            }
            else {
                granularity = .month
            }
            if Calendar.current.isDate(filteredRecords[i].date_time!, equalTo: filteredRecords[i-1].date_time!, toGranularity: granularity) {
                formattedRecords[formattedRecords.count - 1].amount! += filteredRecords[i].amount!
            }
            else {
                formattedRecords.append(filteredRecords[i])
            }
        }
        
        //  Avoid overrun the charts, only display the at most 5 records and display the latest 5 by default.
        if startOfRecord == -2 {
            startOfRecord = max(formattedRecords.count - 5, 0)
        }
        else if startOfRecord < 0 {
            startOfRecord = 0
        }
        else if startOfRecord > formattedRecords.count - 5 {
            startOfRecord = max(formattedRecords.count - 5, 0)
        }
        
        //  Set the default button color.
        leftArrowButton.tintColor = UIColor.tintColor
        rightArrowButton.tintColor = UIColor.tintColor
        
        //  Configure the color of arrow buttons.
        if startOfRecord == 0 {
            leftArrowButton.tintColor = UIColor.lightGray
        }
        if startOfRecord == max(formattedRecords.count - 5, 0) {
            rightArrowButton.tintColor = UIColor.lightGray
        }
        
        var currentPageRecords = [Record]()
        for i in startOfRecord..<min(formattedRecords.count, startOfRecord + 5) {
            currentPageRecords.append(formattedRecords[i])
        }
        
        //  Display the record chart for current page.
        recordChartController?.rootView.updateChartData(recordlist: currentPageRecords)
    }
    
    func updateSavingGraph() {
        //  Initialise chart if no saving plan.
        if savingList == nil || savingList!.isEmpty {
            
            //  Initialise labels.
            currentAmountTextField.text = "Current:"
            targetAmountTextField.text = "Target:"
            remainingDaysTextField.text = "Remain:"
            spentDaysTextField.text = "Spent:"
            startDateTextField.text = "Start Date:"
            endDateTextField.text = "End Date"
            
            //  Initialise chart.
            savingChartController?.rootView.updateChartData(amount: 0.0)
            return
        }
        
        //  Update labels.
        currentAmountTextField.text = "Current: $\(savingList![0].currentAmount!)"
        targetAmountTextField.text = "Target: $\(savingList![0].amount!)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let remainingDays = Calendar.current.dateComponents([.day], from: Date.now, to: savingList![0].end_date!).day!
        remainingDaysTextField.text = "Remain: \(remainingDays) days"
        let spentDats = Calendar.current.dateComponents([.day], from: savingList![0].start_date!, to: Date.now).day!
        spentDaysTextField.text = "Spent: \(spentDats) days"
        
        let endDate = dateFormatter.string(from: savingList![0].end_date!)
        let startDate = dateFormatter.string(from: savingList![0].start_date!)
        startDateTextField.text = "\(startDate)"
        endDateTextField.text = "\(endDate)"
        
        savingChartController?.rootView.updateChartData(amount: Double(savingList![0].currentAmount!)/Double(savingList![0].amount!))
    }
    
    func switchDarkMode() {
        if userDefaults.bool(forKey: "darkmode") {
            UIApplication.shared.keyWindow!.overrideUserInterfaceStyle = .dark
        }
        else {
            UIApplication.shared.keyWindow!.overrideUserInterfaceStyle = .light
        }
    }
    
    func switchTheme() {
        ThemeController.shared.setScheme(rawValue: userDefaults.integer(forKey: "selectedTheme"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //  Theme scheme configuration.
        databaseController?.addListener(listener: self)
        self.view.backgroundColor = ThemeController.shared.backgroundColor
        savingChartController?.rootView.updateChartColor()
        recordChartController?.rootView.updateChartColor()
        self.tabBarController?.tabBar.backgroundColor = ThemeController.shared.tabBarBackgroundColor
        self.tabBarController?.tabBar.tintColor = ThemeController.shared.tintColor
        savingBackgroundView.backgroundColor = ThemeController.shared.cardBackgroundColor
        recordBackgroundView.backgroundColor = ThemeController.shared.cardBackgroundColor
        savingChartView.backgroundColor = ThemeController.shared.cardBackgroundColor
        recordChartView.backgroundColor = ThemeController.shared.cardBackgroundColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
}
