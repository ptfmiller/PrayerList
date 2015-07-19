//
//  PrayerListTableViewController.swift
//  PrayerList
//
//  Created by Miller on 4/17/15.
//  Copyright (c) 2015 Miller. All rights reserved.
//

import UIKit
import Parse


class PrayerListTableViewController: UITableViewController {
    
    let masterList = MasterList.sharedInstance
    var isLoggedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get ready to go with .startUp if the user is already logged in. Otherwise, the viewWillAppear function will direct them to login
        if PFUser.currentUser() != nil {
            masterList.startUp()
            self.isLoggedIn = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loginToPrayerList()
        masterList.fillCalendar()
        //PFUser.logOut()
        self.tableView.reloadData()
    }
    
    func loginToPrayerList() {
        // Don't waste time logging in if you are already
        if self.isLoggedIn {
            return
        }
        
        // Check whether you are already logged in
        var currentUser = PFUser.currentUser()
        if (currentUser != nil) {
            // Record that the user is already logged in
            self.isLoggedIn = true
        }
        else {
            // Show the signup or login screen
            self.performSegueWithIdentifier("login", sender: nil)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return masterList.todaysListLength()
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("prayerRequest", forIndexPath: indexPath) as! RequestTableViewCell
        cell.configureCell(indexPath, listType: RequestTableViewCell.ListType.today)
        return cell
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "editRequest") {
            let cell = sender as! UITableViewCell
            let indexPath = self.tableView.indexPathForCell(cell)
            let navigationController = segue.destinationViewController as! UINavigationController
            let requestEditorViewController = navigationController.topViewController as! RequestEditorViewController
            requestEditorViewController.prayerRequest = masterList.getTodaysList()[indexPath!.row]
        }
        else if (segue.identifier == "addRequest") {
            let navigationController = segue.destinationViewController as! UINavigationController
            let requestEditorViewController = navigationController.topViewController as! RequestEditorViewController
            requestEditorViewController.isNewRequest = true
            requestEditorViewController.prayerRequest = PrayerRequest(requestName: nil, details: nil, frequency: nil)
        }
        else if (segue.identifier == "settings") {
            let settingsViewController = segue.destinationViewController as!  SettingsViewController
            settingsViewController.prayerListTableViewController = self
        }
    }
}
