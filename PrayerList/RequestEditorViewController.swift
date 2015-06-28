//
//  RequestEditorViewController.swift
//  PrayerList
//
//  Created by Miller on 4/17/15.
//  Copyright (c) 2015 Miller. All rights reserved.
//

import UIKit
import Parse

class RequestEditorViewController: UIViewController {
    
    var prayerRequest: PrayerRequest?
    var isNewRequest: Bool = false
    
    @IBOutlet var requestNameTextField: UITextField!
    @IBOutlet var detailsTextView: UITextView!
    @IBOutlet var frequencyPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if (prayerRequest != nil) {
            requestNameTextField.text = prayerRequest?.requestName
            if (prayerRequest?.details != nil) {
                detailsTextView.text = prayerRequest?.details
            } else {
                detailsTextView.text = ""
            }
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
    
    @IBAction func saveWasPressed(sender: AnyObject) {
        // this is really ugly, need to find a way to fix this implementation
        prayerRequest?.requestName = requestNameTextField.text
        prayerRequest?.details = detailsTextView.text
        prayerRequest?.save()
        let masterList = MasterList.sharedInstance
        masterList.fillCalendar()
        self.dismissSelf()
    }

    @IBAction func cancelWasPressed(sender: AnyObject) {
        if (isNewRequest) {
            self.prayerRequest?.delete()
        }
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
