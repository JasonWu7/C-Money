//
//  Saving.swift
//  C-Money
//
//  Created by Dongzheng Wu on 21/4/2023.
//

import UIKit
import FirebaseFirestoreSwift

//  Saving is a target amount that user wants to save for.
class Saving: NSObject, Codable {
    @DocumentID var id: String?
    var method: Int?
    var amount: Int?
    var currentAmount: Int?
    var start_date: Date?
    var end_date: Date?
    var note: String?
    var notification: Bool?
}

enum Method: Int {
    case save_from_expenditure
    case save_from_income
    case save_from_both
    case manual_update
}

enum CodingKeys: String, CodingKey {
    case id
    case method
    case amount
    case start_date
    case end_date
    case note
    case notification
}

extension Saving {
    var savingmethod: Method {
        get {
            return Method(rawValue: self.method!)!
        }
        
        set {
            self.method = newValue.rawValue
        }
    }
}
