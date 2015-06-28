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
    
    
    var _fetchedResultsController: NSFetchedResultsController?
    var requestsList: [PrayerRequest] = []
    var daySelections = [Day.Sunday: true, Day.Monday: true, Day.Tuesday: true, Day.Wednesday: true, Day.Thursday: true, Day.Friday: true, Day.Saturday: true]
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
            var returnval = calendarList[today]!.count
            return calendarList[today]!.count
        } else {return 0}
    }
    
    func deletePrayerRequest(index: Int) {
        let prayerRequest = requestsList[index] as PrayerRequest
        prayerRequest.delete()
        requestsList.removeAtIndex(index)
    }
    
    func startUp() {
        
        // Will need to update this when we move to several users model
        var query = PFQuery(className: "PrayerRequest")
        if let requests = query.findObjects() {
            for item in requests {
                let restoredRequest = PrayerRequest(savedObject: item as! PFObject)
                requestsList.append(restoredRequest)
            }
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
    
    func getTodaysList() -> [PrayerRequest] {
        return calendarList[flattenDate(NSDate())]!
    }
    
    func refreshAllRequests() {
        for request in requestsList {
            request.refreshDates()
            request.save()
        }
    }
}





