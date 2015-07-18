//
//  RequestTableViewCell.swift
//  PrayerList
//
//  Created by Miller on 4/17/15.
//  Copyright (c) 2015 Miller. All rights reserved.
//

import UIKit
import Parse

class RequestTableViewCell: UITableViewCell {
    
    func configureCell(indexpath: NSIndexPath) {
        let masterList = MasterList.sharedInstance
        self.textLabel!.text = masterList.getTodaysList()[indexpath.row].requestName
    }
    
}
