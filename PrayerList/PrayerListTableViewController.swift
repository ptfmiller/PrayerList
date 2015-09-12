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
        
        let singleTapSelector: Selector = "singleTap:"
        let doubleTapSelector: Selector = "doubleTap:"
        
        let singleTap = UITapGestureRecognizer(target: self, action: singleTapSelector)
        let doubleTap = UITapGestureRecognizer(target: self, action: doubleTapSelector)
        
        singleTap.numberOfTapsRequired = 1
        doubleTap.numberOfTapsRequired = 2
        
        singleTap.numberOfTouchesRequired = 1
        doubleTap.numberOfTouchesRequired = 1
        
        // Makes it wait until it knows you are not double-tapping
        singleTap.requireGestureRecognizerToFail(doubleTap)
        
        self.tableView.addGestureRecognizer(singleTap)
        self.tableView.addGestureRecognizer(doubleTap)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loginToPrayerList()
        masterList.fillCalendar()
        self.tableView.reloadData()
    }
    
    func loginToPrayerList() {
        // Don't waste time logging in if you are already
        if self.isLoggedIn {
            return
        }
        
        // Check whether you are already logged in
        if let currentUser = PFUser.currentUser() {
            // Record that the user is already logged in
            self.isLoggedIn = true
        }
        else {
            // Show the signup or login screen
            self.performSegueWithIdentifier("login", sender: nil)
        }
    }
    
    func singleTap(tap: UITapGestureRecognizer) {
        let point: CGPoint = tap.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(point)!
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        if self.rowExistsInDataSource(indexPath) {
            self.performSegueWithIdentifier("editRequest", sender: cell)
        }
    }

    func doubleTap(tap: UITapGestureRecognizer) {
        let point: CGPoint = tap.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(point)!
        if self.rowExistsInDataSource(indexPath) {
            self.flipPrayedIndicator(indexPath)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        var rows = masterList.getTodaysList()[section].count
        if rows == 0 {
            rows = 1
        }
        return rows
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Things to pray for"
        } else {
            return "Prayed for today"
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("prayerRequest", forIndexPath: indexPath) as! RequestTableViewCell
        if masterList.getTodaysList()[indexPath.section].count != 0 {
            cell.configureCell(indexPath, listType: RequestTableViewCell.ListType.today)
        } else {
            if indexPath.section == 0 {
                cell.textLabel?.text = "Nothing left today"
            } else {
                cell.textLabel?.text = "Double-tap to mark done"
            }
        }
        
        return cell
    }
    
    func rowExistsInDataSource(indexPath: NSIndexPath) -> Bool {
        return masterList.getTodaysList()[indexPath.section].count > indexPath.row
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "editRequest") {
            let cell = sender as! UITableViewCell
            let indexPath = self.tableView.indexPathForCell(cell)!
            let requestEditorViewController = segue.destinationViewController as! RequestEditorViewController
            requestEditorViewController.prayerRequest = masterList.getTodaysList()[indexPath.section][indexPath.row]
        }
        else if (segue.identifier == "addRequest") {
            let requestEditorViewController = segue.destinationViewController as! RequestEditorViewController
            requestEditorViewController.isNewRequest = true
            requestEditorViewController.prayerRequest = PrayerRequest()
        }
        else if (segue.identifier == "settings") {
            let settingsViewController = segue.destinationViewController as!  SettingsViewController
            settingsViewController.prayerListTableViewController = self
        }
    }
    
    func flipPrayedIndicator(indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.markRequestDone(indexPath)
        } else {
            self.markRequestNotDone(indexPath)
        }
    }
    
    func markRequestDone(indexPath: NSIndexPath) {
        let todaysList = masterList.getTodaysList()
        let doubleTappedPrayerRequest = todaysList[indexPath.section][indexPath.row]
        
        // Record in the prayer request itself. The masterList automatically contains this information. However, think about updating the way we fill information in the table. The getTodaysList function is called many many times, each time we viewWillAppear. If this continues to get loaded down, we could have performance issues.
        doubleTappedPrayerRequest.recordPrayed(NSDate())
        
        // Animate the row changing places
        self.tableView.beginUpdates()
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
        if self.masterList.getTodaysList()[0].count == 0 {
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        }
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.findPrayerRequestRow(doubleTappedPrayerRequest, section: 1), inSection: 1)], withRowAnimation: UITableViewRowAnimation.Right)
        if self.masterList.getTodaysList()[1].count == 1 {
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Left)
        }
        self.tableView.endUpdates()
    }
    
    func markRequestNotDone(indexPath: NSIndexPath) {
        let todaysList = masterList.getTodaysList()
        let doubleTappedPrayerRequest = todaysList[indexPath.section][indexPath.row]
        
        // Record in the prayer request itself
        doubleTappedPrayerRequest.removePrayed(NSDate())
        
        // Animate the row changing places
        self.tableView.beginUpdates()
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
        if self.masterList.getTodaysList()[1].count == 0 {
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        }
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.findPrayerRequestRow(doubleTappedPrayerRequest, section: 0), inSection: 0)], withRowAnimation: UITableViewRowAnimation.Right)
        if self.masterList.getTodaysList()[0].count == 1 {
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
        }
        self.tableView.endUpdates()
    }
    
    func findPrayerRequestRow(prayerRequest: PrayerRequest, section: Int) -> Int {
        var i = 0
        var found = 0
        let list = self.masterList.getTodaysList()[section]
        for i in 0..<list.count {
            if list[i] === prayerRequest {
                found = i
            }
        }
        return found
    }
}
