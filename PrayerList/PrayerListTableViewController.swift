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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginToPrayerList()
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    func loginToPrayerList() {
        
        
        var currentUser = PFUser.currentUser()
        
        if (currentUser != nil) {
            // Do stuff with the user
            masterList.startUp()

        } else {
            // Show the signup or login screen
            
            // Not working right now.
            
            self.performSegueWithIdentifier("login", sender: nil)
            
            //let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //let loginScreen = storyboard.instantiateViewControllerWithIdentifier("loginScreen") as! loginViewController
            //self.presentViewController(loginScreen, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
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
        return masterList.length()
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("prayerRequest", forIndexPath: indexPath) as! RequestTableViewCell
        cell.configureCell(indexPath)
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
        if (segue.identifier == "addRequest") {
            let navigationController = segue.destinationViewController as! UINavigationController
            let requestEditorViewController = navigationController.topViewController as! RequestEditorViewController
            requestEditorViewController.isNewRequest = true
            requestEditorViewController.prayerRequest = PrayerRequest(requestName: nil, details: nil, frequency: nil)
        }
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
    
}
