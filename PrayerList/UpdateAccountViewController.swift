//
//  UpdateAccountViewController.swift
//  PrayerList
//
//  Created by Miller on 7/18/15.
//  Copyright (c) 2015 Miller. All rights reserved.
//

import UIKit
import Parse

class UpdateAccountViewController: UIViewController {

    @IBOutlet var currentPassword: UITextField!
    @IBOutlet var newPassword: UITextField!
    @IBOutlet var newPasswordConfirm: UITextField!
    @IBOutlet var newEmail: UITextField!
    @IBOutlet var newEmailConfirm: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.currentPassword.placeholder = "current password"
        self.currentPassword.secureTextEntry = true
        
        self.newPassword.placeholder = "new password (optional)"
        self.newPassword.secureTextEntry = true
        self.newPasswordConfirm.placeholder = "confirm new password"
        self.newPasswordConfirm.secureTextEntry = true
        
        self.newEmail.placeholder = "new email (optional)"
        self.newEmail.keyboardType = UIKeyboardType.EmailAddress
        self.newEmailConfirm.placeholder = "confirm new email"
        self.newEmailConfirm.keyboardType = UIKeyboardType.EmailAddress
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func updateAccountWasPressed(sender: AnyObject) {
        // Check to see whether both of either new fields were filled out
        let alert = UIAlertView()
        alert.title = "Error"
        alert.addButtonWithTitle("OK")
        
        if (!self.currentPassword.hasText()) {
            alert.message = "Please enter your current password"
        } else if ((!self.newEmail.hasText() || !self.newEmailConfirm.hasText()) && (!self.newPassword.hasText() || !self.newPasswordConfirm.hasText())) {
            alert.message = "Please enter and confirm either a new password or new email"
        } else {
            if (self.newEmail.hasText() && self.newEmailConfirm.hasText() && self.newPassword.hasText() && self.newPasswordConfirm.hasText()) {
                // We have a full update
                if (self.newEmail.text != self.newEmailConfirm.text) {
                    alert.message = "Emails do not match"
                } else if (self.newPassword.text != self.newPasswordConfirm.text) {
                    alert.message = "Passwords do not match"
                } else {
                    PFUser.currentUser()?.password = self.newPassword.text
                    PFUser.currentUser()?.email = self.newEmail.text
                    alert.title = "Success!"
                    alert.message = "email and password updated"
                }
            } else if (self.newEmail.hasText() && self.newEmailConfirm.hasText()) {
                if (self.newPassword.hasText() || self.newPasswordConfirm.hasText()) {
                    alert.message = "Please fill both new password fields or leave them both empty"
                } else if (self.newEmail.text != self.newEmailConfirm.text) {
                    alert.message = "Emails do not match"
                } else {
                    PFUser.currentUser()?.email = self.newEmail.text
                    alert.title = "Success!"
                    alert.message = "email updated"
                }
            } else if (self.newPassword.hasText() && self.newPasswordConfirm.hasText()) {
                if (self.newEmail.hasText() || self.newEmailConfirm.hasText()) {
                    alert.message = "Please fill both new emails fields or leave them both empty"
                } else if (self.newPassword.text != self.newPasswordConfirm.text) {
                    alert.message = "Passwords do not match"
                } else {
                    PFUser.currentUser()?.password = self.newPassword.text
                    alert.title = "Success!"
                    alert.message = "password updated"
                }
            }
        }
        alert.show()
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
