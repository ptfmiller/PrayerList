//
//  ResetPasswordViewController.swift
//  PrayerList
//
//  Created by Miller on 7/19/15.
//  Copyright (c) 2015 Miller. All rights reserved.
//

import UIKit
import Parse

class ResetPasswordViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextField.placeholder = "email address"
        emailTextField.keyboardType = UIKeyboardType.EmailAddress
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetPasswordWasPressed(sender: AnyObject) {
        if emailTextField.hasText() {
            PFUser.requestPasswordResetForEmailInBackground(emailTextField.text!, block: { (success: Bool, error: NSError?) -> Void in
                if let error = error {
                    let errorString = error.userInfo["error"] as? String
                    let alertView = UIAlertView()
                    alertView.title = "Error"
                    alertView.message = errorString
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                } else {
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        } else {
            let alertView = UIAlertView()
            alertView.title = "Error"
            alertView.message = "Please enter an email address"
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
    }
    
    @IBAction func backWasPressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
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
