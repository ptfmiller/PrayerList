//
//  SignUpViewController.swift
//  PrayerList
//
//  Created by Miller on 7/16/15.
//  Copyright (c) 2015 Miller. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordConfirmTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.emailTextField.placeholder = "email"
        self.emailTextField.keyboardType = UIKeyboardType.EmailAddress
        
        self.passwordTextField.placeholder = "password"
        self.passwordTextField.secureTextEntry = true
        
        self.passwordConfirmTextField.placeholder = "confirm password"
        self.passwordConfirmTextField.secureTextEntry = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signUpWasPressed(sender: AnyObject) {
        if (!self.emailTextField.hasText() || !self.passwordTextField.hasText() || !self.passwordConfirmTextField.hasText() || self.passwordTextField.text != self.passwordConfirmTextField.text) {
            let alert = UIAlertView()
            alert.title = "Login error!"
            if (!self.emailTextField.hasText() && !self.passwordTextField.hasText()) {
                alert.message = "Please enter an email and password"
            } else if (!self.emailTextField.hasText()) {
                alert.message = "Please enter an email"
            } else if (!self.passwordTextField.hasText()){
                alert.message = "Please enter a password"
            } else if (!self.passwordConfirmTextField.hasText()) {
                alert.message = "Please confirm your password"
            } else {
                alert.message = "Passwords do not match"
            }
            alert.addButtonWithTitle("OK")
            alert.show()
        } else {

            var user = PFUser()
            user.username = self.emailTextField.text
            user.password = self.passwordTextField.text
            user.email = self.emailTextField.text
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    let errorString = error.userInfo?["error"] as? String
                    // Show the errorString somewhere and let the user try again.
                    let alert = UIAlertView()
                    alert.title = "Sign up error!"
                    alert.message = errorString
                    alert.addButtonWithTitle("OK")
                    alert.show()
                } else {
                    // Hooray! Let them use the app now.
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func cancelWasPressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
