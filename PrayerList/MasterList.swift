//
//  MasterList.swift
//  PrayerList
//
//  Created by Miller on 4/17/15.
//  Copyright (c) 2015 Miller. All rights reserved.
//

import Foundation
import CoreData
import Parse


private let _MasterList = MasterList()


class MasterList {
    
    var requestsList: [PrayerRequest] = []
    var daySelections = [Day.Sunday: false, Day.Monday: true, Day.Tuesday: true, Day.Wednesday: true, Day.Thursday: true, Day.Friday: true, Day.Saturday: false]
    var calendarList = Dictionary<NSDate, [PrayerRequest]>()
    
    
    enum Day: Int {
        case Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
        
        init(date: NSDate) {
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components(NSCalendarUnit.CalendarUnitWeekday | NSCalendarUnit.CalendarUnitWeekOfYear | NSCalendarUnit.CalendarUnitYear, fromDate: date)
            let weekday = components.weekday
            switch components.weekday {
            case 1: self = .Sunday
            case 2: self = .Monday
            case 3: self = .Tuesday
            case 4: self = .Wednesday
            case 5: self = .Thursday
            case 6: self = .Friday
            case 7: self = .Saturday
            default: self = .Sunday
            }
        }
        
        func equals(day: Day) -> Bool {
            return self.rawValue == day.rawValue
        }
    }
    
    
    class var sharedInstance: MasterList {
        return _MasterList
    }
    
    
    // Returns the length of today's list for the numberOfRowsInSection method
    func todaysListLength() -> Int {
        let today = flattenDate(NSDate())
        if let length = calendarList[today]?.count {
            return length
        }
        else {return 0}
    }
    
    func deletePrayerRequest(request: PrayerRequest) {
        for var i = 0; i < requestsList.count; ++i {
            if (self.requestsList[i] === request) {
                deletePrayerRequest(i)
            }
        }
    }
    
    func deletePrayerRequest(index: Int) {
        let prayerRequest = requestsList[index] as PrayerRequest
        prayerRequest.delete()
        requestsList.removeAtIndex(index)
        self.fillCalendar()
    }
    
    // This function is currently not very safe. I.e. if you try to call it while PFUser is not logged in you will accomplish nothing, and it will not let you know. 
    func startUp() {
        // For inputing data
        /*
        var inputs = [["Jamie", "Daily"]]
        inputs.append(["June", "Daily"])
        inputs.append(["Community Group", "Weekly"])
        inputs.append(["Sang", "Weekly"])
        inputs.append(["Aron Dalley", "Weekly"])
        inputs.append(["Kevin McDermott", "Weekly"])
        inputs.append(["Matt Becker", "Weekly"])
        inputs.append(["Jason Plamp", "Weekly"])
        inputs.append(["Julian Cha", "Weekly"])
        inputs.append(["James Ortego", "Weekly"])
        inputs.append(["Dad", "Weekly"])
        inputs.append(["Mom", "Weekly"])
        inputs.append(["Heather", "Weekly"])
        inputs.append(["Andrew", "Weekly"])
        inputs.append(["Cannon", "Weekly"])
        inputs.append(["Melissa and Andy", "Weekly"])
        inputs.append(["Paul Kherer", "Weekly"])
        inputs.append(["Remnant", "Weekly"])
        inputs.append(["Richmond", "Weekly"])
        inputs.append(["Will Squiers", "Weekly"])
        inputs.append(["PFA", "Weekly"])
        inputs.append(["Westminster Intervarsity", "Weekly"])
        inputs.append(["Pawkuele", "Weekly"])
        inputs.append(["Max Gruenther", "Weekly"])
        inputs.append(["Revival", "Weekly"])
        inputs.append(["Persecuted Christians", "Weekly"])
        inputs.append(["Jerrard Smith", "Weekly"])
        inputs.append(["Malcom Norris", "Biweekly"])
        inputs.append(["Sean Pyle", "Biweekly"])
        inputs.append(["Bryan Laughlin", "Biweekly"])
        inputs.append(["Josh Soto", "Biweekly"])
        inputs.append(["Doug Ponder", "Biweekly"])
        inputs.append(["Jason Elliot", "Biweekly"])
        inputs.append(["Darrel Bowe", "Biweekly"])
        inputs.append(["Christian Union", "Biweekly"])
        inputs.append(["Government", "Biweekly"])
        inputs.append(["Chad and Jessica", "Biweekly"])
        inputs.append(["Brenda", "Biweekly"])
        inputs.append(["Bob and Paulette", "Biweekly"])
        inputs.append(["Matt Superdock", "Biweekly"])
        inputs.append(["Graheks", "Biweekly"])
        inputs.append(["Sarah Dorrance", "Biweekly"])
        inputs.append(["Warren Lewis", "Biweekly"])
        inputs.append(["Grace Robinson", "Biweekly"])
        inputs.append(["Jenika", "Biweekly"])
        inputs.append(["Leanne", "Biweekly"])
        inputs.append(["Erika", "Biweekly"])
        inputs.append(["Shanna", "Biweekly"])
        inputs.append(["Yogi", "Biweekly"])
        inputs.append(["Youssef", "Biweekly"])
        inputs.append(["Paul Eiker", "Biweekly"])
        inputs.append(["David Babylon", "Biweekly"])
        inputs.append(["Frank Babylon", "Biweekly"])
        inputs.append(["Louis Paumier", "Biweekly"])
        inputs.append(["Nick Uebel ministry at VCU", "Biweekly"])
        inputs.append(["Ryan Modi", "Biweekly"])
        inputs.append(["Dan Casanova", "Fourweekly"])
        inputs.append(["Danny Weiss", "Fourweekly"])
        inputs.append(["Dave Kurz", "Fourweekly"])
        inputs.append(["Trent Fuenmayor", "Fourweekly"])
        inputs.append(["Jim Hao", "Fourweekly"])
        inputs.append(["John Naberhaus", "Fourweekly"])
        inputs.append(["Peter Breen", "Fourweekly"])
        inputs.append(["Bree Hierholzer", "Fourweekly"])
        inputs.append(["Jack Squiers", "Fourweekly"])
        inputs.append(["Matt Becker", "Fourweekly"])
        inputs.append(["Redeemer Church in Leeds", "Fourweekly"])
        inputs.append(["Village Church in Belfast", "Fourweekly"])
        inputs.append(["Jesus Rodriguez in Mexico City", "Fourweekly"])
        inputs.append(["Billy and Holly", "Fourweekly"])
        inputs.append(["Nate & Kat Snead", "Fourweekly"])
        inputs.append(["Catherine Ham", "Fourweekly"])
        inputs.append(["Matt and Sandra", "Fourweekly"])
        inputs.append(["Xida Zheng", "Fourweekly"])
        inputs.append(["Judson Kempton", "Fourweekly"])
        inputs.append(["Corey Lightner", "Fourweekly"])
        inputs.append(["Lenny Levin", "Fourweekly"])
        inputs.append(["Greg Palmer", "Fourweekly"])
        inputs.append(["Ryan Schneider", "Fourweekly"])
        inputs.append(["Rich Fairbank", "Fourweekly"])
        inputs.append(["Scott Jones", "Fourweekly"])
        inputs.append(["Luke Bonner", "Fourweekly"])
        inputs.append(["Joe Duerksen", "Fourweekly"])
        inputs.append(["Daniel Graves", "Fourweekly"])
        inputs.append(["Ryan Compton", "Fourweekly"])
        inputs.append(["Christian Briggs", "Fourweekly"])
        inputs.append(["Rachel Robbins", "Fourweekly"])

        for item in inputs {
            let newRequest = PrayerRequest(requestName: item[0], details: nil, frequency: PrayerRequest.Frequency(choice: item[1]))
            newRequest.save()
            requestsList.append(newRequest)
        }
        */
        
        /*
        var user = PFUser()
        user.username = "ptfmiller@gmail.com"
        user.password = "S1mplexity"
        user.email = "ptfmiller@gmail.com"
        
        user.signUpInBackgroundWithBlock {
        (succeeded: Bool, error: NSError?) -> Void in
        if let error = error {
        let errorString = error.userInfo?["error"] as? NSString
        // Show the errorString somewhere and let the user try again.
        print(errorString)
        } else {
        // Hooray! Let them use the app now.
        }
        }
        */
        
        
        var currentUser = PFUser.currentUser()
        if currentUser != nil {
            // Do stuff with the user
            // Will need to update this when we move to several users model
            var query = PFQuery(className: "PrayerRequest")
            query.whereKey("user", equalTo: currentUser!)
            if let requests = query.findObjects() {
                for item in requests {
                    let restoredRequest = PrayerRequest(savedObject: item as! PFObject)
                    self.addPrayerRequest(restoredRequest)
                }
            }
        }
        
        self.fillCalendar()
    
        //PFUser.logOut()
    }
    
    func addPrayerRequest(prayerRequest: PrayerRequest) {
        self.requestsList.append(prayerRequest)
    }
    
    func fillCalendar() {
        self.calendarList = Dictionary<NSDate, [PrayerRequest]>()
        for prayerRequest in requestsList {
            for date in prayerRequest.dates {
                if (calendarList[date] != nil) {
                    calendarList[date]?.append(prayerRequest)
                } else {
                    let newList = [prayerRequest]
                    calendarList[date] = newList
                }
            }
        }
    }
    
    func flattenDate(date: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.CalendarUnitWeekday | NSCalendarUnit.CalendarUnitWeekOfYear | NSCalendarUnit.CalendarUnitYear, fromDate: date)
        return calendar.dateFromComponents(components)!
    }
    
    func validDate(date: NSDate) -> Bool {
        let day = Day(date: date)
        let bool = self.daySelections[day]!
        return bool
    }
    
    func getTodaysList() -> [PrayerRequest] {
        return calendarList[flattenDate(NSDate())]!
    }
    
    func refreshAllRequests() {
        for request in requestsList {
            request.refreshDates()
            request.save()
        }
    }
    
    func clear() {
        self.requestsList = []
        self.daySelections = [Day.Sunday: false, Day.Monday: true, Day.Tuesday: true, Day.Wednesday: true, Day.Thursday: true, Day.Friday: true, Day.Saturday: false]
        self.calendarList = Dictionary<NSDate, [PrayerRequest]>()
        
    }
}





