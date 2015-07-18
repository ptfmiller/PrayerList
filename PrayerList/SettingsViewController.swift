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

    // Messy implementation. Think about changing.
    var prayerListTableViewController: PrayerListTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backWasPressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func logoutWasPressed(sender: AnyObject) {
        PFUser.logOut()
        let masterList = MasterList.sharedInstance
        masterList.clear()
        self.prayerListTableViewController?.isLoggedIn = false
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func viewAllPrayerTopicsWasPressed(sender: AnyObject) {
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
