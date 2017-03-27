//
//  KeyboardHandlingMechanism.swift
//  2day
//
//  Created by Anastasiya Dumyak on 27.02.17.
//  Copyright © 2017 Inoxoft Solutions. All rights reserved.
//

import UIKit

class KeyboardHandlingMechanism: NSObject {

    var scrollView: UIScrollView?
    var controller: UIViewController!
    var activeTextField: UITextField?
    var bottomConstraintForKeyboard: NSLayoutConstraint!
    var tapGesture: UITapGestureRecognizer!
    var bottomValue: Double?
    fileprivate var keyboardBottomConstraintDefaulValue: CGFloat = 10
    fileprivate let animationDuration = 0.2

    func registerForKeyboardNotifications(_ controller: UIViewController, scrollView: UIScrollView?, bottomConstraint: NSLayoutConstraint) {
        self.scrollView = scrollView
        self.controller = controller
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(KeyboardHandlingMechanism.hideKeyboard))
        self.controller.view.addGestureRecognizer(tapGesture)
        bottomConstraintForKeyboard = bottomConstraint
        keyboardBottomConstraintDefaulValue = bottomConstraint.constant
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardHandlingMechanism.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardHandlingMechanism.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func addActiveTextField(_ activeTextView: UITextField) {
        activeTextField = activeTextView
    }
    
    func unregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardDidShow(_ notification: Notification) {
        let info = notification.userInfo!
        guard let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size else { return }
        let height = keyboardSize.height
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, height, 0.0)
        scrollView?.contentInset = contentInsets
        scrollView?.scrollIndicatorInsets = contentInsets
        var aRect : CGRect = controller.view.frame
        aRect.size.height -= keyboardSize.height
         bottomConstraintForKeyboard.constant = keyboardSize.height
        UIView.animate(withDuration: 0.3) { 
            self.controller.view.layoutIfNeeded()
        }

        if let textField = activeTextField {
            if aRect.contains(textField.frame.origin) == false {
                scrollView?.scrollRectToVisible(textField.frame, animated: true)
            }
        }
    }
    
    
    func hideKeyboard() {
        self.controller.view.endEditing(true)
    }

    func keyboardWillHide(_ notification: Notification) {
        scrollView?.contentInset = UIEdgeInsets.zero
        scrollView?.scrollIndicatorInsets = UIEdgeInsets.zero
        self.controller.view.layoutIfNeeded()
        bottomConstraintForKeyboard.constant = keyboardBottomConstraintDefaulValue
        UIView.animate(withDuration: animationDuration, animations: { self.controller.view.layoutIfNeeded() }) 
    }
}
