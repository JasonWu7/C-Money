//
//  Progresses.swift
//  C-Money
//
//  Created by Dongzheng Wu on 16/5/2023.
//

import UIKit

//  Progresses is a collection of Progress objects.
class Progresses: NSObject, Codable {
    var id: String?
    var progress = [Progress]()
}
