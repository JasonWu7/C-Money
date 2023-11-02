//
//  SettingViewController.swift
//  C-Money
//
//  Created by Dongzheng Wu on 18/4/2023.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var notificationBGView: UIView!
    @IBOutlet weak var darkmodeBGView: UIView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var darkmodeSwitch: UISwitch!
    
    var darkmodeOn: Bool?
    var notificationOff: Bool?
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        notificationBGView.layer.cornerRadius = 10
        darkmodeBGView.layer.cornerRadius = 10
        //  Do any additional setup after loading the view.
        
        //  Initialise darkmode switch
        darkmodeOn = userDefaults.bool(forKey: "darkmode")
        darkmodeSwitch.isOn = darkmodeOn!
        
        //  Initialise notification switch
        notificationOff = userDefaults.bool(forKey: "notificationOff")
        notificationSwitch.isOn = !notificationOff!
    }
    
    @IBAction func goToHelpDocument(_ sender: Any) {
        if let url = URL(string: "https://github.com/Jason-fc/HELP_DOCUMENT/blob/main/README.md") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func notificationSwitchValueChanged(_ sender: Any) {
        if notificationSwitch.isOn {
            userDefaults.set(false, forKey: "notificationOff")
        }
        else {
            userDefaults.set(true, forKey: "notificationOff")
        }
    }
    
    @IBAction func darkmodeSwitchValueChanged(_ sender: Any) {
         if darkmodeSwitch.isOn {
             userDefaults.set(true, forKey: "darkmode")
            }
         else {
             userDefaults.set(false, forKey: "darkmode")
         }
        switchDarkMode()
    }
    
    //  Turn on and off dark mode, applied to all the screens.
    func switchDarkMode() {
        if userDefaults.bool(forKey: "darkmode") {
            UIApplication.shared.keyWindow!.overrideUserInterfaceStyle = .dark
        }
        else{
            UIApplication.shared.keyWindow!.overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //  Theme configuration.
        self.view.backgroundColor = ThemeController.shared.backgroundColor
        self.tabBarController?.tabBar.backgroundColor = ThemeController.shared.tabBarBackgroundColor
        self.tabBarController?.tabBar.tintColor = ThemeController.shared.tintColor
        self.navigationController?.navigationBar.tintColor = ThemeController.shared.tintColor
    }
}
