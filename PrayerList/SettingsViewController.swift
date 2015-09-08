//
//  SettingsViewController.swift
//  PrayerList
//
//  Created by Miller on 7/17/15.
//  Copyright (c) 2015 Miller. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UITableViewController {

    @IBOutlet var switchSunday: UISwitch!
    @IBOutlet var switchMonday: UISwitch!
    @IBOutlet var switchTuesday: UISwitch!
    @IBOutlet var switchWednesday: UISwitch!
    @IBOutlet var switchThursday: UISwitch!
    @IBOutlet var switchFriday: UISwitch!
    @IBOutlet var switchSaturday: UISwitch!

    // Messy implementation. Think about changing.
    var prayerListTableViewController: PrayerListTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }

    override func viewWillAppear(animated: Bool) {
        let masterList = MasterList.sharedInstance
        let selections = masterList.getDaySelections()
        switchSunday.on = selections[MasterList.Day.Sunday]!
        switchMonday.on = selections[MasterList.Day.Monday]!
        switchTuesday.on = selections[MasterList.Day.Tuesday]!
        switchWednesday.on = selections[MasterList.Day.Wednesday]!
        switchThursday.on = selections[MasterList.Day.Thursday]!
        switchFriday.on = selections[MasterList.Day.Friday]!
        switchSaturday.on = selections[MasterList.Day.Saturday]!
    }

    override func viewWillDisappear(animated: Bool) {
        let masterList = MasterList.sharedInstance
        var newSelections = Dictionary<MasterList.Day, Bool>()
        newSelections[MasterList.Day.Sunday] = switchSunday.on
        newSelections[MasterList.Day.Monday] = switchMonday.on
        newSelections[MasterList.Day.Tuesday] = switchTuesday.on
        newSelections[MasterList.Day.Wednesday] = switchWednesday.on
        newSelections[MasterList.Day.Thursday] = switchThursday.on
        newSelections[MasterList.Day.Friday] = switchFriday.on
        newSelections[MasterList.Day.Saturday] = switchSaturday.on
        // If an update is needed, this function will perform the update and refresh all prayer requests so they fall on the correct days
        masterList.mayUpdateDaySelections(newSelections)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logoutWasPressed(sender: AnyObject) {
        PFUser.logOut()
        let masterList = MasterList.sharedInstance
        masterList.clear()
        self.prayerListTableViewController?.isLoggedIn = false
        self.navigationController?.popViewControllerAnimated(true)
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
