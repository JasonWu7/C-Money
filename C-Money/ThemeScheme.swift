//
//  ThemeScheme.swift
//  C-Money
//
//  Created by Dongzheng Wu on 1/6/2023.
//

import Foundation
import UIKit

enum Scheme {
    case normal
    case passion
    case calm
    case peace
}

protocol ThemeScheme: AnyObject {
    var scheme: Scheme {get set}
    var backgroundColor: UIColor {get}
    var textColor: UIColor {get}
    var tabBarBackgroundColor: UIColor {get}
    var tintColor: UIColor {get}
    var cardBackgroundColor: UIColor {get}
}
