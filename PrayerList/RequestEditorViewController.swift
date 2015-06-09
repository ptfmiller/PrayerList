//
//  RequestEditorViewController.swift
//  PrayerList
//
//  Created by Miller on 4/17/15.
//  Copyright (c) 2015 Miller. All rights reserved.
//

import UIKit
//import Parse

class RequestEditorViewController: UIViewController {
    
    var prayerRequest: PrayerRequest?
    @IBOutlet var requestNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if (prayerRequest != nil) {
            requestNameTextField.text = prayerRequest?.requestName
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func receivePrayerRequest(prayerRequest: PrayerRequest) {
        self.prayerRequest = prayerRequest
    }
    
    func dismissSelf() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneWasPressed(sender: AnyObject) {
        if (prayerRequest != nil) {
            // this is really ugly, need to find a way to fix this implementation
            prayerRequest?.requestName = requestNameTextField.text
        } else {
            
        }
        self.dismissSelf()
    }
    
    @IBAction func cancelWasPressed(sender: AnyObject) {
        self.dismissSelf()
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
