//
//  LoginSettingViewController.swift
//  C-Money
//
//  Created by Dongzheng Wu on 18/5/2023.
//

import UIKit
import FirebaseAuth


class LoginSettingViewController: UIViewController {

    @IBOutlet weak var oldPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    weak var databaseController: DatabaseProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    @IBAction func changePassword(_ sender: Any) {
        //  Input fields validations.
        guard let newPassword = newPasswordField.text, let confirmPassword = confirmPasswordField.text, let oldPassword = oldPasswordField.text else {
            return
        }
        if newPassword.isEmpty || confirmPassword.isEmpty || oldPassword.isEmpty {
            displayMessage(title: "Fails", message: "Please enter all the fields.")
            return
        }
        if newPassword != confirmPassword {
            displayMessage(title: "Fails", message: "Your entered passwords not consistent.")
            return
        }
        
        //  Reauthentication from user using old passwor.
        let user = Auth.auth().currentUser
        var credential: AuthCredential?
        credential = EmailAuthProvider.credential(withEmail: (databaseController?.currentUser!.email)!, password: oldPassword)
        guard let userCredential = credential else {
            displayMessage(title: "Error", message: "Incorrect credential.")
            return
        }
        user?.reauthenticate(with: userCredential) { result, error in
            if error != nil {
                self.displayMessage(title: "Error", message: "Invalid password.")
                return
            }
            else {
                //  Reset user's password.
                Auth.auth().currentUser?.updatePassword(to: newPassword)
                self.displayMessage(title: "Success", message: "Your password has been updated.")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //  Theme configuration.
        self.view.backgroundColor = ThemeController.shared.backgroundColor
    }
}
