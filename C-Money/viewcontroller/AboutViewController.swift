//
//  AboutViewController.swift
//  C-Money
//
//  Created by Dongzheng Wu on 7/6/2023.
//

import UIKit

class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        //  Theme configuration.
        self.view.backgroundColor = ThemeController.shared.backgroundColor
    }
}
