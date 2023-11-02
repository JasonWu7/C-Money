//
//  Progress.swift
//  C-Money
//
//  Created by Dongzheng Wu on 16/5/2023.
//

import UIKit
import FirebaseFirestoreSwift

//  Progress is the progress of saving, consisted with date and amoount.
class Progress: NSObject, Codable {
    @DocumentID var id: String?
    var amount: Int?
    var date: Date?
    
    func getDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.short
        return dateFormatter.string(from: date!)
    }
}
