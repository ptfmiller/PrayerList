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
    var todaysList = [Int, PrayerRequest]()
    
    
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
        
        init(value: Int) {
            switch value {
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
        
        func dayNumber() -> Int {
            return self.rawValue
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
    
    func masterListLength() -> Int {
        return requestsList.count
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
    
    func startUp() {
        if let currentUser = PFUser.currentUser() {
            var query = PFQuery(className: "PrayerRequest")
            query.whereKey("user", equalTo: currentUser)
            if let requests = query.findObjects() {
                for item in requests {
                    let restoredRequest = PrayerRequest(savedObject: item as! PFObject)
                    self.addPrayerRequest(restoredRequest)
                }
            }
            self.fetchDaySelections()
        }
        self.fillCalendar()
    }
    
    func fetchDaySelections() {
        if let currentUser = PFUser.currentUser() {
            if let selections = currentUser["daySelections"] as? [Bool] {
                var masterSelections = Dictionary<Day, Bool>()
                for i in 1..<selections.count {
                    let day = Day(rawValue: i)
                    masterSelections[day!] = selections[i]
                }
                self.daySelections = masterSelections
            } else {
                self.updateDaySelections(self.daySelections)
            }
        }
    }
    
    func getDaySelections() -> Dictionary<Day, Bool> {
        return self.daySelections
    }
    
    func mayUpdateDaySelections(newSelections: Dictionary<Day, Bool>) {
        var updateNeeded: Bool = false
        for (day, bool) in newSelections {
            if bool != self.daySelections[day] {
                updateNeeded = true
            }
        }
        if updateNeeded {
            self.updateDaySelections(newSelections)
            self.refreshAllRequests()
        }        
    }
    
    // Converts the dictionary into the array to be stored in the PFUser, since PFUser dictionaries cannot store Day enums. Then calls
    func updateDaySelections(selections: Dictionary<Day, Bool>) {
        var boolArray = [Bool](count:8, repeatedValue: false)
        for (day, bool) in selections {
                boolArray[day.dayNumber()] = bool
        }
        self.updateDaySelections(boolArray)
    }
    
    func updateDaySelections(selections: [Bool]) {
        if let currentUser = PFUser.currentUser() {
            currentUser["daySelections"] = selections
            currentUser.saveInBackground()
        } else {
            // There was a problem. There should necessarily be a PFUser.
        }
        self.fetchDaySelections()
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
    
    func getTodaysList() -> [[PrayerRequest]] {
        var todaysList = [calendarList[flattenDate(NSDate())]!,[]]
        var i = 0
        while i < todaysList[0].count {
            // if the if condition is never met, then the date is in the past and should not be reset
            if todaysList[0][i].doneToday() {
                // The date is still to come, and we need to replace it
                todaysList[1].append(todaysList[0][i])
                todaysList[0].removeAtIndex(i)
                i -= 1
            }
            i += 1
        }
        return todaysList
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





