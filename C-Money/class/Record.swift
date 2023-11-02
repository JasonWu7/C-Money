//
//  Record.swift
//  C-Money
//
//  Created by Dongzheng Wu on 21/4/2023.
//

import UIKit
import FirebaseFirestoreSwift

//  Record is the detail of recorded expenditure or income.
class Record: NSObject, Codable {
    @DocumentID var id: String?
    var category: String?
    var amount: Int?
    var date_time: Date?
    var note: String?
    var location: String?
    
    func getDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.short
        return dateFormatter.string(from: date_time!)
    }
}
