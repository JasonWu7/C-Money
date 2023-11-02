//
//  TabBarController.swift
//  C-Money
//
//  Created by Dongzheng Wu on 18/4/2023.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Style configuration.
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
