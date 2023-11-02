//
//  Savings.swift
//  C-Money
//
//  Created by Dongzheng Wu on 2/5/2023.
//

import UIKit

//  Savings is a collection of Saving objects.
class Savings: NSObject, Codable {
    var id: String?
    var saving = [Saving]()
}
