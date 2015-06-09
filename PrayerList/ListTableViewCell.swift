//
//  RequestTableViewCell.swift
//  PrayerList
//
//  Created by Miller on 4/17/15.
//  Copyright (c) 2015 Miller. All rights reserved.
//

import UIKit
//import Parse

class RequestTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(indexpath: NSIndexPath) {
        let masterList = MasterList.sharedInstance
        self.textLabel!.text = masterList.getTodaysList()[indexpath.row].requestName
    }
    
}
