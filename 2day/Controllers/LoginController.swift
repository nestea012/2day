//
//  LoginController.swift
//  2day
//
//  Created by Anastasiya Dumyak on 3/14/17.
//  Copyright © 2017 AnastasiyaDumiak. All rights reserved.
//

import UIKit
import FirebaseAuth
import MBProgressHUD

class LoginController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var loginSegmentedControl: UISegmentedControl!
    @IBOutlet weak var emailTexField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var nameHeightConstraint: NSLayoutConstraint!
    
    var textFieldArray: [UITextField] = []
    var keyboardHandler = KeyboardHandlingMechanism()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTextFields()
    }

    func setupUI() {
        view.layer.contents = UIImage(named: "loginPageImage")?.cgImage
        view.layer.contentsGravity = kCAGravityResizeAspectFill
        keyboardHandler.registerForKeyboardNotifications(self, scrollView: nil, bottomConstraint: bottomConstraint)
    }
    
    @IBAction func changedMode(_ sender: Any) {
        if loginSegmentedControl.selectedSegmentIndex == 0 {
            nameHeightConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: { 
                self.view.layoutIfNeeded()
            })
        } else {
            nameHeightConstraint.constant = 35
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    @IBAction func loginDidTap(_ sender: Any) {
        if loginSegmentedControl.selectedSegmentIndex == 0 {
            login()
        } else {
            createAccount()
        }
    }
}

extension LoginController {
    func createAccount() {
        if (!self.isConnectedToNetwork()) {
            Alerts.showAlertWith(title: "Error", description: "Network is missing", controller: self)
            return
        }
        
        if !isEmailValid(testStr: emailTexField.text!),passwordTextField.text == "",passwordTextField.text!.characters.count < 6 {
            return
        }
        
        showProgressIndicator()
        
        FIRAuth.auth()?.createUser(withEmail: emailTexField.text!, password: passwordTextField.text!) { (user, error) in
            self.hideProgressIndicator()
            if (error != nil) {
                Alerts.showAlertWith(title: "Error", description: error?.localizedDescription ?? "", controller: self)
                return
            }
            
            user?.sendEmailVerification(completion: { (error) in
                print("Verification has sent")
            })
            
            DispatchQueue.main.async(execute: {
                self.goNext()
            })
        }
    }
    
    func login() {
        if !isEmailValid(testStr: emailTexField.text!),passwordTextField.text == "",passwordTextField.text!.characters.count < 6 {
            Alerts.showAlertWith(title: "Error", description: "Invalid email or Incorrect length of password", controller: self)
            return
        }
        
        showProgressIndicator()
        FIRAuth.auth()?.signIn(withEmail: emailTexField.text!, password: passwordTextField.text!) { (user, error) in
            if let error = error {
                self.hideProgressIndicator()
                Alerts.showAlertWith(title: "Error", description: error.localizedDescription, controller: self)
            } else {
                self.hideProgressIndicator()
                self.goNext()
            }
        }
    }
    
    func goNext() {
        UserManager.sharedInstance.createNewUser(nameTextField.text!, password: passwordTextField.text!, email: emailTexField.text!)
        if (UserManager.sharedInstance.checkUserInformation()) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func showProgressIndicator() {
        MBProgressHUD.showAdded(to: view, animated: true)
    }
    
    func hideProgressIndicator() {
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    func isEmailValid(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}

extension LoginController {
    
    func setupTextFields() {
        textFieldArray = [emailTexField, passwordTextField, nameTextField]
        nameTextField.delegate = self
        emailTexField.delegate = self
        passwordTextField.delegate = self
       
    }
    
    func hideKeyboard() {
        self.view.endEditing(false)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.autocorrectionType = .no
        if textField != textFieldArray.last {
            textField.returnKeyType = .next
        } else {
            textField.returnKeyType = .done
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTexField {
            textField.returnKeyType = .done
            passwordTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let characterSet = NSMutableCharacterSet()
        characterSet.formUnion(with: NSCharacterSet.alphanumerics)
        characterSet.addCharacters(in: ".@_!#$%&'*+-/=?^_`{|}~")
        if string.rangeOfCharacter(from: characterSet.inverted) != nil {
            return false
        }
        
        if textField == emailTexField && string != "" {
            if ((textField.text?.characters.count)!  > 30) {
                return false
            }
        }
        
        if textField == passwordTextField && string != "" {
            if ((textField.text?.characters.count)!  > 20) {
                return false
            }
        }
        
        return true
    }
}
