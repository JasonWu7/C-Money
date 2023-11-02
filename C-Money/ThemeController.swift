//
//  ThemeController.swift
//  C-Money
//
//  Created by Dongzheng Wu on 1/6/2023.
//

import UIKit

class ThemeController: NSObject, ThemeScheme {
    static let shared = ThemeController()       //  Singleton/Static to allow all the class access to the same configuration.
    var scheme: Scheme
    
    //  Default theme setting
    var backgroundColor = UIColor.systemGray5
    var textColor = UIColor.black
    var tabBarBackgroundColor: UIColor = UIColor.systemGray4
    var tintColor: UIColor = UIColor.systemBlue
    var cardBackgroundColor: UIColor = UIColor.white
    
    override init() {
        self.scheme = .normal
    }
    
    func switchTheme(themeScheme: Scheme) {
        scheme = themeScheme
        updateColorScheme()
    }
    
    func setScheme(rawValue: Int) {
        switch rawValue {
        case 0:
            scheme = .normal
        case 1:
            scheme = .passion
        case 2:
            scheme = .calm
        case 3:
            scheme = .peace
        default:
            scheme = .normal
        }
        updateColorScheme()
    }
    
    //  Configure the color scheme based on scheme category.
    func updateColorScheme() {
        switch scheme {
        case .normal:
            backgroundColor = UIColor.systemGray5
            textColor = UIColor.label
            tabBarBackgroundColor = UIColor.systemGray4
            tintColor = UIColor.systemBlue
            cardBackgroundColor = UIColor.systemBackground
        case .calm:
            backgroundColor = UIColor(named: "BackgroundCalmColor")!
            textColor = UIColor.label
            tabBarBackgroundColor = UIColor(named: "TabBarCalmColor")!
            tintColor = UIColor(named: "TintCalmColor")!
            cardBackgroundColor = UIColor(named: "CardCalmColor")!
        case .passion:
            backgroundColor = UIColor(named: "BackgroundPassionColor")!
            textColor = UIColor.label
            tabBarBackgroundColor = UIColor(named: "TabBarPassionColor")!
            tintColor = UIColor(named: "TintPassionColor")!
            cardBackgroundColor = UIColor(named: "CardPassionColor")!
        case .peace:
            backgroundColor = UIColor(named: "BackgroundPeaceColor")!
            textColor = UIColor.label
            tabBarBackgroundColor = UIColor(named: "TabBarPeaceColor")!
            tintColor = UIColor(named: "TintPeaceColor")!
            cardBackgroundColor = UIColor(named: "CardPeaceColor")!
        }
    }
    
    //  Used to show the preview in theme setting page.
    func getPreviewColor(rawValue: Int) -> UIColor {
        switch rawValue {
        case 0:
            return UIColor.systemGray5
        case 1:
            return UIColor(named: "BackgroundPassionColor")!
        case 2:
            return UIColor(named: "BackgroundCalmColor")!
        case 3:
            return UIColor(named: "BackgroundPeaceColor")!
        default:
            return UIColor.systemGray5
        }
    }
}
