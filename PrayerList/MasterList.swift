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
    
    let prayerListItemNames = [
        "Jamie",
        "June",
        "Community Group",
        "Matt Becker",
        "Julian Cha",
        "Dad",
        "Mom",
        "Heather",
        "Andrew",
        "Cannon",
        "Melissa and Andy"
    ]
    
    var _fetchedResultsController: NSFetchedResultsController?
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
    
    
    // To be removed/edited later
    func length() -> Int {
        let today = flattenDate(NSDate())
        if calendarList[today] != nil {
            return calendarList[today]!.count
        } else {return 0}
    }
    
    
    func addPrayerRequest(name: String) {
        let newRequest = PrayerRequest(name: name, details: nil, frequency: PrayerRequest.Frequency.weekly)
        requestsList.append(newRequest)
    }
    
    func deletePrayerRequest(index: Int) {
        requestsList.removeAtIndex(index)
    }
    
    func updatePrayerRequest(index: Int, newName: String) {
        requestsList[index].requestName = newName
    }
    
    
    func startUp() {
        // To be removed later
        for item in prayerListItemNames {
            self.addPrayerRequest(item)
        }
        self.fillCalendar()
        /*       let testObject = PFObject(className: "TestObject")
        testObject["foo"] = "bar"
        testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
        println("Object has been saved.")
        }
        */ }
    
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
    
    // Not currently in use
    func requestName(indexPath: NSIndexPath) -> String {
        let date = flattenDate(NSDate())
        let listForToday = calendarList[date]
        let prayerRequest = listForToday![indexPath.row]
        return prayerRequest.requestName
    }
    
    func getTodaysList() -> [PrayerRequest] {
        return calendarList[flattenDate(NSDate())]!
    }
    
}





