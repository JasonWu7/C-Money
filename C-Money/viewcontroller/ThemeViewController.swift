//
//  ThemeViewController.swift
//  C-Money
//
//  Created by Dongzheng Wu on 1/6/2023.
//

import UIKit

class ThemeViewController: UIViewController {

    @IBOutlet weak var themeSegmented: UISegmentedControl!
    @IBOutlet weak var previewText: UILabel!
    @IBOutlet weak var previewView: UIView!
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Set the segmented valua and vieww to corresponding theme.
        themeSegmented.selectedSegmentIndex = userDefaults.integer(forKey: "selectedTheme")
        previewView.backgroundColor = ThemeController.shared.getPreviewColor(rawValue: themeSegmented.selectedSegmentIndex)
    }

    @IBAction func themeSegmentedChange(_ sender: Any) {
        previewView.backgroundColor = ThemeController.shared.getPreviewColor(rawValue: themeSegmented.selectedSegmentIndex)
    }
    
    @IBAction func confirmChange(_ sender: Any) {
        //  Change the color scheme and store the configuration to userdefault.
        ThemeController.shared.setScheme(rawValue: themeSegmented.selectedSegmentIndex)
        ThemeController.shared.updateColorScheme()
        userDefaults.setValue(themeSegmented.selectedSegmentIndex, forKey: "selectedTheme")
        
        //  Update the layout based on color scheme.
        self.tabBarController?.tabBar.backgroundColor = ThemeController.shared.backgroundColor
        self.tabBarController?.tabBar.tintColor = ThemeController.shared.tintColor
        navigationController?.popViewController(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //  Theme configuration.
        self.view.backgroundColor = ThemeController.shared.backgroundColor
    }
}
