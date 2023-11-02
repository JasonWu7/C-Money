//
//  ViewController.swift
//  C-Money
//
//  Created by Dongzheng Wu on 31/3/2023.
//
//  REFERENCE:
//  https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
//  Aknowledgement has been made in the aknowledgement section in setting page, appreciate again for the author and creator of corresponding blogs and tools.

import UIKit
import SwiftUI
import FirebaseAuth
import LocalAuthentication


class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet var backgroundView: UIView!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    weak var databaseController: DatabaseProtocol?
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Configure the gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds       //  Set the size of layer to the same size of display.
        gradientLayer.colors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor]
        gradientLayer.shouldRasterize = true
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)      //  Top left corner.
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)        //  Bottom right corner.
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        //  Add delegate to textfield for implmentation of dismiss keyboard by tapping enter.
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        //  Active biometric authentication login.
        activeLocalAuth()
    }
    
    func activeLocalAuth() {
        //  Test if user is logged in using this device.
        if databaseController?.authController.currentUser?.email == nil {
            return
        }

        //  Create local authentication context.
        let context = LAContext()
        
        //  Customize text on guide button.
        context.localizedCancelTitle = "Use Password to log in"
        
        //  Test policy availability.
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            displayMessage(title: "Tips", message: "Enable biometric authentication to log in with faceID")
            return
        }
        
        //  Create dispatch group to ensure the user has logged in before seting up listeners.
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        Task {
            do {
                //  Evaluate policy.
                try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Log in to your account")
                
                //  Use the existing user to login.
                databaseController?.currentUser = databaseController?.authController.currentUser
                
                dispatchGroup.leave()
            } catch let error {
                print(error.localizedDescription)
                return
            }
        }
        
        //  Uses completion handler to ensure all the listeners have been set up before segueing.
        let completionHandler = {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "mainpageSegue", sender: self)
            }
        }
        
        var completionCount = 0
        let finishCount = 3
        
        let setupListenerCompletionHandler = {
            completionCount += 1
            if completionCount == finishCount {
                completionHandler()
            }
        }
        
        //  Once user has completed login, set up listeners and make sure they are completed.
        dispatchGroup.notify(queue: .main) {
            self.databaseController?.setupRecordListener(completion: setupListenerCompletionHandler)
            self.databaseController?.setupSavingListener(completion: setupListenerCompletionHandler)
            self.databaseController?.setupProgressListener(completion: setupListenerCompletionHandler)
        }
    }

    @IBAction func signup(_ sender: Any) {
        databaseController?.signout()
        if inputValidation(){
            Auth.auth().fetchSignInMethods(forEmail: emailTextField.text!){ signInMethods, error in
                if ((signInMethods?.contains(EmailPasswordAuthSignInMethod)) != nil) {
                    self.displayMessage(title: "Already Exists", message: "Your email already been registered!")
                    return
                }
            }
            userDefaults.setValue(true, forKey: "HasLoggedIn")
            databaseController?.signup(email: emailTextField.text!, password: passwordTextField.text!)
        }
    }
    
    @IBAction func login(_ sender: Any) {
        databaseController?.signout()
        if inputValidation() {
            Task {
                do {
                    let authDataResult = try await databaseController!.authController.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!)
                    databaseController!.currentUser = authDataResult.user
                }
                catch {
                    displayMessage(title: "Login Fails", message: "Incorrect email or password")
                    return
                }
            }
        }
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        //  Check if the email field is empty.
        guard let email = emailTextField.text else {
            displayMessage(title: "Notice", message: "Please Enter the Email")
            return
        }
        if email.isEmpty {
            displayMessage(title: "Notice", message: "Please Enter the Email")
            return
        }
        
        //  Send the reset password link to user's email.
        Auth.auth().sendPasswordReset(withEmail: email)
        displayMessage(title: "Success", message: "A reset password link has been sent to your email.")
    }
    
    func inputValidation() -> Bool{
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return false
        }
        if email.isEmpty || password.isEmpty {
            var errorMsg = "Please ensure all fields are filled:\n"
            if email.isEmpty {
                errorMsg += "- Must provide a valid email\n"
            }
            if password.isEmpty {
                errorMsg += "- Must provide a valid password"
            }
            displayMessage(title: "Empty fields", message: errorMsg)
        }
        
        if password.count < 6 {
            displayMessage(title: "Fails", message: "Password must be 6 characters long or more")
        }
        
        //  Email format checking.
        let regularExpresion = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        let emailPredictate = NSPredicate(format: "SELF MATCHES %@", regularExpresion)
        if !email.isEmpty && emailPredictate.evaluate(with: email) == false{
            displayMessage(title: "Invalid Email", message: "Please enter a valid email\n e.g. Example@gmail.com")
        }
        return emailPredictate.evaluate(with: email)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //  Dismiss keyboard when tapping enter.
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener{auth, user in
            if user != nil{
                if user?.email == self.emailTextField.text?.lowercased() {
                    self.databaseController?.currentUser = self.databaseController?.authController.currentUser

                    //  Uses completion handler to ensure all the listeners have been set up before segueing.
                    var completionCount = 0
                    let finishCount = 3
                    
                    let completionHandler = {
                        
                        //  Notify the user and ask them to reopen the app if they reinstalled app and use old account. This avoid a unfixable bug where everytime user use existing account to login after reinstalled the app, the data cannot be retrieved from firebase (and I worked on this bug for over weeks and it seems the issue with firebase which cannot be resolved from my end.)
                        if self.userDefaults.bool(forKey: "HasLoggedIn") == false {
                            self.userDefaults.setValue(true, forKey: "HasLoggedIn")
                            let alertController = UIAlertController(title: "Notice", message: "This is the first time you log in after reinstalled the app, due to security issue you are required to re-open the application and login again, thank you!", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "Okay", style: .default,handler: {_ in exit(0)}))
                            self.present(alertController, animated: true, completion: nil)
                        }
                        else {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "mainpageSegue", sender: self)
                            }
                        }
                    }

                    let setupListenerCompletionHandler = {
                        completionCount += 1
                        if completionCount == finishCount {
                            completionHandler()
                        }
                    }
                    
                    //  Set up the listners and make sure they completed.
                    self.databaseController?.setupRecordListener(completion: setupListenerCompletionHandler)
                    self.databaseController?.setupSavingListener(completion: setupListenerCompletionHandler)
                    self.databaseController?.setupProgressListener(completion: setupListenerCompletionHandler)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let handle = handle else {
            return
        }
        Auth.auth().removeStateDidChangeListener(handle)
    }
}
