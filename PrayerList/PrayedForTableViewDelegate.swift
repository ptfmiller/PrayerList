//
//  PrayedForTableViewDelegate.swift
//  PrayerList
//
//  Created by Miller on 9/10/15.
//  Copyright (c) 2015 Miller. All rights reserved.
//

import Foundation
import UIKit

class PrayedForTableViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var prayerRequest: PrayerRequest?
    
    func setPrayerRequest(prayerRequest: PrayerRequest?) {
        self.prayerRequest = prayerRequest
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.prayerRequest!.prayerRecord.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("prayedForCell", forIndexPath: indexPath) 
        let date = prayerRequest?.prayerRecord[indexPath.row]
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        cell.textLabel?.text = dateFormatter.stringFromDate(date!)
        return cell
    }
    
    func heightOfTable() -> Int {
        return prayerRequest!.prayerRecord.count * 44
    }
    
}
