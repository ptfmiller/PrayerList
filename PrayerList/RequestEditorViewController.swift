//
//  RequestEditorViewController.swift
//  PrayerList
//
//  Created by Miller on 4/17/15.
//  Copyright (c) 2015 Miller. All rights reserved.
//

import UIKit
import Parse

class RequestEditorViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate, UITextViewDelegate {
    
    var prayerRequest: PrayerRequest?
    var isNewRequest: Bool = false
    let prayedForTableViewDelegate = PrayedForTableViewDelegate()
    let detailsPlaceHolderText = "Optional"

    
    @IBOutlet var requestNameTextField: UITextField!
    @IBOutlet var detailsTextView: UITextView!
    @IBOutlet var frequencyPicker: UIPickerView!
    
    @IBOutlet var switchSunday: UISwitch!
    @IBOutlet var switchMonday: UISwitch!
    @IBOutlet var switchTuesday: UISwitch!
    @IBOutlet var switchWednesday: UISwitch!
    @IBOutlet var switchThursday: UISwitch!
    @IBOutlet var switchFriday: UISwitch!
    @IBOutlet var switchSaturday: UISwitch!
    
    @IBOutlet var prayedForTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var prayedForContainerView: UIView!
    @IBOutlet var prayedForTableView: UITableView!
    
    @IBOutlet var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.prayedForTableViewDelegate.setPrayerRequest(self.prayerRequest)
        self.prayedForTableView.delegate = self.prayedForTableViewDelegate
        self.prayedForTableView.dataSource = self.prayedForTableViewDelegate
        self.frequencyPicker.dataSource = self
        self.frequencyPicker.delegate = self
        if (prayerRequest != nil) {
            requestNameTextField.text = prayerRequest?.requestName
            if (prayerRequest?.details != nil) {
                detailsTextView.text = prayerRequest?.details
            } else {
                self.detailsTextView.text = self.detailsPlaceHolderText
                self.detailsTextView.textColor = UIColor.lightGrayColor()
            }
            self.frequencyPicker.selectRow(prayerRequest!.frequency.rawValue - 1, inComponent: 0, animated: true)
        } else {
            self.detailsTextView.text = self.detailsPlaceHolderText
            self.detailsTextView.textColor = UIColor.lightGrayColor()
        }
        
        // Set capitalization and placeholder text for the name and details
        self.requestNameTextField.autocapitalizationType = .Words
        self.detailsTextView.autocapitalizationType = .Sentences
        self.requestNameTextField.placeholder = "Name this prayer topic"
        self.detailsTextView.delegate = self
        
        // Set navigation for the name and details text view keyboards
        
    }
    
    override func viewWillAppear(animated: Bool) {
        let switchesDictionary = [MasterList.Day.Sunday: switchSunday, MasterList.Day.Monday: switchMonday, MasterList.Day.Tuesday: switchTuesday, MasterList.Day.Wednesday: switchWednesday, MasterList.Day.Thursday: switchThursday, MasterList.Day.Friday: switchFriday, MasterList.Day.Saturday: switchSaturday]

        let masterList = MasterList.sharedInstance
        let masterListSelections = masterList.getDaySelections()
        let prayerRequestSelections = self.prayerRequest?.getValidDays()
        for (day, uiSwitch) in switchesDictionary {
            uiSwitch.enabled = masterListSelections[day]!
            if uiSwitch.enabled {
                if let current = prayerRequestSelections?[day] {
                    uiSwitch.on = current
                }
            } else {
                uiSwitch.on = false
            }
        }
        self.prayedForContainerView.sizeToFit()
        self.prayedForTableView.sizeToFit()
        var height = self.prayedForTableView.contentSize.height;
        let maxHeight = self.prayedForTableView.superview!.frame.size.height - self.prayedForTableView.frame.origin.y;
        
        
        // if the height of the content is greater than the maxHeight of
        // total space on the screen, limit the height to the size of the
        // superview.
        
        if (height > maxHeight) {
        height = maxHeight;
        }
        
        // now set the height constraint accordingly
        
        
        self.prayedForTableViewHeightConstraint.constant = height;
        self.view.setNeedsUpdateConstraints()
        
        
    }
    
    // Pickerview necessities follow
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PrayerRequest.Frequency.numberOfFrequencyOptions()
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PrayerRequest.Frequency.listOfOptions()[row]
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "System", size: 10)
            pickerLabel?.textAlignment = NSTextAlignment.Center
        }
        pickerLabel?.text = PrayerRequest.Frequency.listOfOptions()[row]
        return pickerLabel!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 4 && indexPath.row == 0) {
            return CGFloat(prayedForTableViewDelegate.heightOfTable())
        }
        else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    func receivePrayerRequest(prayerRequest: PrayerRequest) {
        self.prayerRequest = prayerRequest
    }
    
    func dismissSelf() {
        //self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func saveWasPressed(sender: AnyObject) {
        if self.requestNameTextField.text!.isEmpty {
            let alertView = UIAlertView(title: "Error", message: "Please enter a name for this prayer topic", delegate: self, cancelButtonTitle: "OK")
            alertView.show()
        } else {
            self.prayerRequest?.setName(requestNameTextField.text)
            if self.detailsTextView.text != self.detailsPlaceHolderText {
                self.prayerRequest?.setDetails(detailsTextView.text)
            }
            let frequencySelection = frequencyPicker.selectedRowInComponent(0)
            let switchesDictionary = [MasterList.Day.Sunday: switchSunday, MasterList.Day.Monday: switchMonday, MasterList.Day.Tuesday: switchTuesday, MasterList.Day.Wednesday: switchWednesday, MasterList.Day.Thursday: switchThursday, MasterList.Day.Friday: switchFriday, MasterList.Day.Saturday: switchSaturday]
            var newSelections = Dictionary<MasterList.Day, Bool>()
            for (day, uiSwitch) in switchesDictionary {
                newSelections[day] = uiSwitch.on
            }
            // If an update is needed, this function will perform the update and refresh all prayer requests so they fall on the correct days
            prayerRequest?.mayUpdateDaySelections(newSelections)
            prayerRequest?.mayUpdateFrequency(frequencySelection)
        
        
            prayerRequest?.save()
            let masterList = MasterList.sharedInstance
            if self.isNewRequest {
                masterList.addPrayerRequest(self.prayerRequest!)
            }
            // This is here so the list will update based on the new information
            masterList.fillCalendar()
            self.dismissSelf()
        }
    }

    /*@IBAction func cancelWasPressed(sender: AnyObject) {
        if (isNewRequest) {
            self.prayerRequest?.delete()
        }
        self.dismissSelf()
    }*/
    
    @IBAction func deleteWasPressed(sender: AnyObject) {
        let alertView = UIAlertView(title: "Delete this prayer request?", message: "Please confirm", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Delete")
        alertView.show()        
    }

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            let masterList = MasterList.sharedInstance
            masterList.deletePrayerRequest(self.prayerRequest!)
            self.dismissSelf()
        }
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        self.detailsTextView.textColor = UIColor.blackColor()
        if(self.detailsTextView.text == detailsPlaceHolderText) {
            self.detailsTextView.text = ""
        }
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if(textView.text == "") {
            self.detailsTextView.text = detailsPlaceHolderText
            self.detailsTextView.textColor = UIColor.lightGrayColor()
        }
    }
    
    
    
}
