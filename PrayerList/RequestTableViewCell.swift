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
    
    enum ListType {
        case today, master
    }
    
    func configureCell(indexpath: NSIndexPath, listType: ListType) {
        let masterList = MasterList.sharedInstance
        switch listType {
        case .today: self.textLabel!.text = masterList.getTodaysList()[indexpath.row].requestName
        case .master: self.textLabel!.text = masterList.requestsList[indexpath.row].requestName
        }
    }
}
