//
//  loginViewController.swift
//  PrayerList
//
//  Created by Miller on 7/12/15.
//  Copyright (c) 2015 Miller. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        let user = PFUser.currentUser()
        if user != nil {
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.emailTextField.placeholder = "email"
        self.emailTextField.keyboardType = UIKeyboardType.EmailAddress
        
        self.passwordTextField.placeholder = "password"
        self.passwordTextField.secureTextEntry = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginWasPressed(sender: AnyObject) {
        if (!self.emailTextField.hasText() || !self.passwordTextField.hasText()) {
            let alert = UIAlertView()
            alert.title = "Login error!"
            if (!self.emailTextField.hasText() && !self.passwordTextField.hasText()) {
                alert.message = "Please enter an email and password"
            } else if (!self.emailTextField.hasText()) {
                alert.message = "Please enter an email"
            } else {
                alert.message = "Please enter a password"
            }
            alert.addButtonWithTitle("OK")
            alert.show()
        } else {
        
            PFUser.logInWithUsernameInBackground(self.emailTextField.text, password:self.passwordTextField.text) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    // Do stuff after successful login.
                    let masterList = MasterList.sharedInstance
                    masterList.startUp()
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    // The login failed. Check error to see why.
                    let alert = UIAlertView()
                    alert.title = "Login error!"
                    alert.message = error?.description
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
            }
        }
    }

    @IBAction func signUpWasPressed(sender: AnyObject) {
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
