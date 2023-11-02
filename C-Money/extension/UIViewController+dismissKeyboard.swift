//
//  UIViewController+dismissKeyboard.swift
//  C-Money
//
//  Created by Dongzheng Wu on 27/4/2023.
//
//  REFERENCE:
//  https://stackoverflow.com/questions/67494196/uitapgesturerecognizer-to-hide-keyboard-taps-on-uitableviewcell
//  Aknowledgement has been made in the aknowledgement section in setting page, appreciate again for the author and creator of corresponding blogs and tools.

import UIKit

//  The extension is used to dismiss the keyboad when user tapping the area other than textfield.
extension UIViewController {
    func dismissKeyboardWhenTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard as () -> Void))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
