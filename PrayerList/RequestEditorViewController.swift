//
//  RequestEditorViewController.swift
//  PrayerList
//
//  Created by Miller on 4/17/15.
//  Copyright (c) 2015 Miller. All rights reserved.
//

import UIKit
import Parse

class RequestEditorViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var prayerRequest: PrayerRequest?
    var isNewRequest: Bool = false
    
    @IBOutlet var requestNameTextField: UITextField!
    @IBOutlet var detailsTextView: UITextView!
    @IBOutlet var frequencyPicker: UIPickerView!
    @IBOutlet var deleteButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        detailsTextView.layer.cornerRadius = 5
        detailsTextView.layer.borderColor = UIColor.grayColor().CGColor
        detailsTextView.layer.borderWidth = 1
        
        deleteButton.setBackgroundImage(UIImage(named: "iphone_delete_button.png")?.stretchableImageWithLeftCapWidth(8, topCapHeight: 0), forState: UIControlState.Normal)
        deleteButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        deleteButton.titleLabel?.font = UIFont.boldSystemFontOfSize(20)
        deleteButton.titleLabel?.shadowColor = UIColor.lightGrayColor()
        deleteButton.titleLabel?.shadowOffset = CGSizeMake(0, -1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.frequencyPicker.dataSource = self
        self.frequencyPicker.delegate = self
        if (prayerRequest != nil) {
            requestNameTextField.text = prayerRequest?.requestName
            if (prayerRequest?.details != nil) {
                detailsTextView.text = prayerRequest?.details
            } else {
                detailsTextView.text = ""
            }
            self.frequencyPicker.selectRow(prayerRequest!.frequency.rawValue - 1, inComponent: 0, animated: true)
        }
    }
    
    
    
    // Pickerview necessities follow
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PrayerRequest.Frequency.numberOfFrequencyOptions()
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return PrayerRequest.Frequency.listOfOptions()[row]
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
        let frequencySelection = frequencyPicker.selectedRowInComponent(0)
        prayerRequest?.frequency = PrayerRequest.Frequency(choice: frequencySelection + 1)
        prayerRequest?.save()
        let masterList = MasterList.sharedInstance
        // So this is not updating the calendar to retrieve the object once you save it, so the calendar remains without the item. Need to fix.
        masterList.fillCalendar()
        self.dismissSelf()
    }

    @IBAction func cancelWasPressed(sender: AnyObject) {
        if (isNewRequest) {
            self.prayerRequest?.delete()
        }
        self.dismissSelf()
    }
    
    @IBAction func deleteWasPressed(sender: AnyObject) {
        // NEED TO ADD SOME CONFIRMATION BUTTON HERE
        let masterList = MasterList.sharedInstance
        masterList.deletePrayerRequest(self.prayerRequest!)
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
