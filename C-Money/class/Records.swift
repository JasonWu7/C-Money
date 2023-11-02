//
//  Records.swift
//  C-Money
//
//  Created by Dongzheng Wu on 27/4/2023.
//

import UIKit

//  Records is a collection of Record objects.
class Records: NSObject, Codable {
    var id: String?
    var record = [Record]()
}
