//
//  RequestEditorViewController.swift
//  PrayerList
//
//  Created by Miller on 4/17/15.
//  Copyright (c) 2015 Miller. All rights reserved.
//

import UIKit
import Parse

class RequestEditorViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate {
    
    var prayerRequest: PrayerRequest?
    var isNewRequest: Bool = false
    
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
    
    
    @IBOutlet var deleteButton: UIButton!
    
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
    
    override func viewWillAppear(animated: Bool) {
        var switchesDictionary = [MasterList.Day.Sunday: switchSunday, MasterList.Day.Monday: switchMonday, MasterList.Day.Tuesday: switchTuesday, MasterList.Day.Wednesday: switchWednesday, MasterList.Day.Thursday: switchThursday, MasterList.Day.Friday: switchFriday, MasterList.Day.Saturday: switchSaturday]

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
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var pickerLabel = view as? UILabel
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "System", size: 10)
            pickerLabel?.textAlignment = NSTextAlignment.Center
        }
        pickerLabel?.text = PrayerRequest.Frequency.listOfOptions()[row]
        return pickerLabel!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func receivePrayerRequest(prayerRequest: PrayerRequest) {
        self.prayerRequest = prayerRequest
    }
    
    func dismissSelf() {
        //self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func saveWasPressed(sender: AnyObject) {
        // this is really ugly, need to find a way to fix this implementation
        prayerRequest?.requestName = requestNameTextField.text
        prayerRequest?.details = detailsTextView.text
        let frequencySelection = frequencyPicker.selectedRowInComponent(0)
        if prayerRequest?.frequency != PrayerRequest.Frequency(choice: frequencySelection + 1) {
            prayerRequest?.frequency = PrayerRequest.Frequency(choice: frequencySelection + 1)
            prayerRequest?.refreshDates()
        }
        var switchesDictionary = [MasterList.Day.Sunday: switchSunday, MasterList.Day.Monday: switchMonday, MasterList.Day.Tuesday: switchTuesday, MasterList.Day.Wednesday: switchWednesday, MasterList.Day.Thursday: switchThursday, MasterList.Day.Friday: switchFriday, MasterList.Day.Saturday: switchSaturday]
        var newSelections = Dictionary<MasterList.Day, Bool>()
        for (day, uiSwitch) in switchesDictionary {
            newSelections[day] = uiSwitch.on
        }
        // If an update is needed, this function will perform the update and refresh all prayer requests so they fall on the correct days
        prayerRequest?.mayUpdateDaySelections(newSelections)

        
        prayerRequest?.save()
        let masterList = MasterList.sharedInstance
        if self.isNewRequest {
            masterList.addPrayerRequest(self.prayerRequest!)
        }
        // This is here so the list will update based on the new information
        masterList.fillCalendar()
        self.dismissSelf()
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
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
