//
//  SettingsViewController.swift
//  PrayerList
//
//  Created by Miller on 7/17/15.
//  Copyright (c) 2015 Miller. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController {

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

    // We will uncomment once this functionality is fully coded
/*
    override func viewWillAppear(animated: Bool) {
        let masterList = MasterList.sharedInstance
        let selections = masterList.daySelections
        let current = selections[MasterList.Day.Monday]!
        let day = MasterList.Day.Monday
        switchSunday.on = selections[MasterList.Day.Sunday]!
        switchMonday.on = selections[MasterList.Day.Monday]!
        switchTuesday.on = selections[MasterList.Day.Tuesday]!
        switchWednesday.on = selections[MasterList.Day.Wednesday]!
        switchThursday.on = selections[MasterList.Day.Thursday]!
        switchFriday.on = selections[MasterList.Day.Friday]!
        switchSaturday.on = selections[MasterList.Day.Saturday]!
        let on = switchMonday.on
        let onS = switchSunday.on
    }
    
    // Doesn't successfully set the values in the masterlist yet
    override func viewWillDisappear(animated: Bool) {
        let masterList = MasterList.sharedInstance
        masterList.daySelections[MasterList.Day.Sunday] = switchSunday.on
        masterList.daySelections[MasterList.Day.Monday] = switchMonday.on
        masterList.daySelections[MasterList.Day.Tuesday] = switchTuesday.on
        masterList.daySelections[MasterList.Day.Wednesday] = switchWednesday.on
        masterList.daySelections[MasterList.Day.Thursday] = switchThursday.on
        masterList.daySelections[MasterList.Day.Friday] = switchFriday.on
        masterList.daySelections[MasterList.Day.Saturday] = switchSaturday.on
    }
*/
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
