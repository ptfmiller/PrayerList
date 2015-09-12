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
    
    func configureCell(indexPath: NSIndexPath, listType: ListType) {
        let masterList = MasterList.sharedInstance
        switch listType {
        case .today: self.textLabel!.text = masterList.getTodaysList()[indexPath.section][indexPath.row].requestName
        case .master: self.textLabel!.text = masterList.requestsList[indexPath.row].requestName
        }
    }
}
