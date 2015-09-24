//
//  PrayerRequest.swift
//  PrayerList
//
//  Created by Miller on 4/17/15.
//  Copyright (c) 2015 Miller. All rights reserved.
//

import Foundation
import Parse

let _secondsInDay: NSTimeInterval = 24 * 60 * 60
let _daysInWeek = 7
let _secondsInThreeWeeks: NSTimeInterval = 21 * _secondsInDay
let _daysInFourWeeks = _daysInWeek * 4
let _firstDayOfWeek = 1
let _lastDayOfWeek = _daysInWeek


class PrayerRequest {
    enum Frequency: Int {
        case daily = 1, weekly, biweekly, fourweekly
        
        // Init function serves to enable us to reinstate from the dictionary of a PFObject
        init(choice: Int?) {
            if choice != nil {
                switch choice! {
                case 1: self = .daily
                case 2: self = .weekly
                case 3: self = .biweekly
                case 4: self = .fourweekly
                default: self = .daily
                }
            }
            else {self = .daily}
        }
        
        init(choice: String) {
            switch choice {
            case "Daily": self = .daily
            case "Weekly": self = .weekly
            case "Once every two weeks": self = .biweekly
            case "Biweekly": self = .biweekly
            case "Once every four weeks": self = .fourweekly
            case "Fourweekly": self = .fourweekly
            default: self = .daily
            }
        }
        
        // Not currently used and not sure whether I will end up using it.
        func frequencyName() -> String {
            switch self {
            case .daily: return "Daily"
            case .weekly: return "Weekly"
            case .biweekly: return "Once every two weeks"
            case .fourweekly: return "Once every four weeks"
            }
        }
        
        static func numberOfFrequencyOptions() -> Int {
            return 4
        }
        
        static func listOfOptions() -> [String] {
            return ["Daily", "Weekly", "Once every two weeks", "Once every four weeks"]
        }
    }
    
    
    var requestName: String? = ""
    var details: String? = ""
    var dateFrameStart: NSDate = NSDate()
    var dateFrameEnd: NSDate = NSDate()
    var frequency: Frequency = Frequency(choice: nil)
    var dates: [NSDate] = []
    var prayerRecord: [NSDate] = []
    var validDays = Dictionary<MasterList.Day, Bool>()
    var saveObject = PFObject(className: "PrayerRequest")
    
    var completeRefresh = false

    // Only used by the requestEditor when you add a request, called through the main tableviewcontroller
    init() {
        self.requestName = nil
        self.details = nil
        
        let calendar = NSCalendar.currentCalendar()
        
        let startComponents = calendar.components([NSCalendarUnit.Weekday, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Year], fromDate: NSDate())
        startComponents.weekday = _firstDayOfWeek
        self.dateFrameStart = flattenDate(calendar.dateFromComponents(startComponents)!)
        
        let endComponents = calendar.components([NSCalendarUnit.Weekday, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Year], fromDate: NSDate(timeIntervalSinceNow: _secondsInThreeWeeks))
        endComponents.weekday = _lastDayOfWeek
        self.dateFrameEnd = flattenDate(calendar.dateFromComponents(endComponents)!)
    }
    
    init(requestName: String, details: String?, dateFrameStart: NSDate, dateFrameEnd: NSDate, dates: [NSDate], frequency: Frequency, validDays: Dictionary<MasterList.Day, Bool>, prayerRecord: [NSDate], saveObject: PFObject) {
        self.requestName = requestName
        self.details = details
        self.dateFrameStart = dateFrameStart
        self.dateFrameEnd = dateFrameEnd
        self.dates = dates
        self.frequency = frequency
        self.prayerRecord = prayerRecord
        self.validDays = validDays
        self.saveObject = saveObject
        
        let today = NSDate()
        if today.compare(self.dateFrameEnd) == .OrderedDescending {
            // We have exited the date frame of the current randomization
            let calendar = NSCalendar.currentCalendar()

            let startComponents = calendar.components([NSCalendarUnit.Weekday, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Year], fromDate: NSDate())
            startComponents.weekday = _firstDayOfWeek
            self.dateFrameStart = flattenDate(calendar.dateFromComponents(startComponents)!)
            
            let endComponents = calendar.components([NSCalendarUnit.Weekday, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Year], fromDate: NSDate(timeIntervalSinceNow: _secondsInThreeWeeks))
            endComponents.weekday = _lastDayOfWeek
            self.dateFrameEnd = flattenDate(calendar.dateFromComponents(endComponents)!)
            
            self.dates = []
            self.completeRefresh = true
            self.refreshDates()
        }
    }
    
    // Init from a retrieved PFObject
    convenience init(savedObject: PFObject) {
        let requestName = savedObject["requestName"] as! String
        var details: String? = nil
        if (savedObject["details"] !== NSNull()) {
            details = savedObject["details"] as! String?
        }
        let dateFrameStart = savedObject["dateFrameStart"] as! NSDate
        let dateFrameEnd = savedObject["dateFrameEnd"] as! NSDate
        let dates = savedObject["dates"] as! [NSDate]
        let frequency = Frequency(choice: savedObject["frequency"] as! Int?)
        var validDaysDictionary = Dictionary<MasterList.Day, Bool>()
        if let validDaysArray = savedObject["validDays"] as? [Bool] {
            for i in 1...(validDaysArray.count - 1) {
                let day = MasterList.Day(value: i)
                validDaysDictionary[day] = validDaysArray[i]
            }
        } else {
            let masterList = MasterList.sharedInstance
            let masterDaySelections = masterList.getDaySelections()
            validDaysDictionary = masterDaySelections
        }
        var prayerRecord: [NSDate] = []
        if let retrievedPrayerRecord = savedObject["prayerRecord"] as? [NSDate] {
            prayerRecord = retrievedPrayerRecord
        }
        
        self.init(requestName: requestName, details: details, dateFrameStart: dateFrameStart, dateFrameEnd: dateFrameEnd, dates: dates, frequency: frequency, validDays: validDaysDictionary, prayerRecord: prayerRecord, saveObject: savedObject)
    }
    
    func save() {
        if (self.requestName == nil) {
            saveObject["requestName"] = NSNull()
        } else {
            saveObject["requestName"] = self.requestName
        }
        if (self.details == nil) {
            saveObject["details"] = NSNull()
        } else {
            saveObject["details"] = self.details
        }
        saveObject["dateFrameStart"] = self.dateFrameStart
        saveObject["dateFrameEnd"] = self.dateFrameEnd
        saveObject["dates"] = self.dates
        saveObject["frequency"] = self.frequency.rawValue
        saveObject["prayerRecord"] = self.prayerRecord
        saveObject["validDays"] = self.convertDictionaryToBoolArray(self.validDays)
        
        // Store the current user for retrieving later
        let user = PFUser.currentUser()
        saveObject["user"] = user
        saveObject.saveInBackground()
    }
    
    func delete() {
        saveObject.deleteInBackground()
    }
    
    func setName(name: String?) {
        self.requestName = name
    }
    
    func setDetails(details: String?) {
        self.details = details
    }
    
    func convertBoolArrayToDictionary(boolArray: [Bool]) -> Dictionary<MasterList.Day, Bool> {
        var newDic = Dictionary<MasterList.Day, Bool>()
        for i in 1...(boolArray.count - 1) {
            let day = MasterList.Day(value: i)
            newDic[day] = boolArray[i]
        }
        return newDic
    }
    
    func convertDictionaryToBoolArray(dic: Dictionary<MasterList.Day, Bool>) -> [Bool] {
        var boolArray = [Bool](count:8, repeatedValue: false)
        for (day, bool) in dic {
            boolArray[day.dayNumber()] = bool
        }
        return boolArray
    }
    
    func mayUpdateFrequency(frequencySelection: Int) {
        if self.frequency != Frequency(choice: frequencySelection + 1) {
            self.frequency = Frequency(choice: frequencySelection + 1)
            self.dates = []
            self.refreshDates()
        }
    }
    
    // Need to update this to remove some abberant behavior. If we refresh something with a not daily recurrence, we could have the same item twice this week. Or not at all. Daily recurrences should simply have all dates cleared and added back in. The way to do this is probably moving the dates clearing to within the cases individually.
    // Additionally, need to code this to start actually using the valid day preferences.
    func refreshDates() {
        let masterList = MasterList.sharedInstance
        let calendarList = masterList.calendarList
        var possibleDates = createCandidateDates()
        
        // perform weighting based on calendarList's fullness
        for (date, _) in possibleDates {
            if (calendarList[date] != nil) {
                possibleDates.updateValue(possibleDates[date]! * pow(0.5, Double(calendarList[date]!.count)), forKey: date)
            }
        }
        
        switch frequency {
        case .daily: self.fillDailyPrayerRequest(possibleDates)
        case .weekly: self.fillWeeklyPrayerRequest(possibleDates, dateFrameStart: dateFrameStart, dateFrameEnd: dateFrameEnd)
        case .biweekly: self.fillBiweeklyPrayerRequest(possibleDates, dateFrameStart: dateFrameStart, dateFrameEnd: dateFrameEnd)
        case .fourweekly: self.fillFourweeklyPrayerRequest(possibleDates, dateFrameStart: dateFrameStart, dateFrameEnd: dateFrameEnd)
        }
        
        self.save()
        masterList.fillCalendar()
    }
    
    func fillDailyPrayerRequest(possibleDates: Dictionary<NSDate, Double>) {
        self.dates = []
        for (date, distribution) in possibleDates {
            if (distribution > 0) {
                dates.append(date)
            }
        }
    }
    
    func fillWeeklyPrayerRequest(possibleDates: Dictionary<NSDate, Double>, dateFrameStart: NSDate, dateFrameEnd: NSDate) {
        // First week
        var frameStart = dateFrameStart
        var frameEnd = flattenDate(NSDate(timeInterval: _secondsInDay * Double(_daysInWeek - 1), sinceDate: dateFrameStart))
        self.mayAddRandomDate(possibleDates, frameStart: frameStart, frameEnd: frameEnd)
        
        // Second week
        frameStart = flattenDate(NSDate(timeInterval: _secondsInDay * Double(_daysInWeek), sinceDate: dateFrameStart))
        frameEnd = flattenDate(NSDate(timeInterval: _secondsInDay * Double(_daysInWeek * 2 - 1), sinceDate: dateFrameStart))
        self.mayAddRandomDate(possibleDates, frameStart: frameStart, frameEnd: frameEnd)
        
        // Third week
        frameStart = flattenDate(NSDate(timeInterval: _secondsInDay * Double(_daysInWeek * 2), sinceDate: dateFrameStart))
        frameEnd = flattenDate(NSDate(timeInterval: _secondsInDay * Double(_daysInWeek * 3 - 1), sinceDate: dateFrameStart))
        self.mayAddRandomDate(possibleDates, frameStart: frameStart, frameEnd: frameEnd)
        
        // Fourth week
        frameStart = flattenDate(NSDate(timeInterval: _secondsInDay * Double(_daysInWeek * 3), sinceDate: dateFrameStart))
        frameEnd = dateFrameEnd
        self.mayAddRandomDate(possibleDates, frameStart: frameStart, frameEnd: frameEnd)

    }
    
    func fillBiweeklyPrayerRequest(possibleDates: Dictionary<NSDate, Double>, dateFrameStart: NSDate, dateFrameEnd: NSDate) {
        // First fortnight
        var frameStart = dateFrameStart
        var frameEnd = flattenDate(NSDate(timeInterval: _secondsInDay * Double(_daysInWeek * 2 - 1), sinceDate: dateFrameStart))
        self.mayAddRandomDate(possibleDates, frameStart: frameStart, frameEnd: frameEnd)
        
        // Second fortnight
        frameStart = flattenDate(NSDate(timeInterval: _secondsInDay * Double(_daysInWeek * 2), sinceDate: dateFrameStart))
        frameEnd = dateFrameEnd
        self.mayAddRandomDate(possibleDates, frameStart: frameStart, frameEnd: frameEnd)
    }
    
    func fillFourweeklyPrayerRequest(possibleDates: Dictionary<NSDate, Double>, dateFrameStart: NSDate, dateFrameEnd: NSDate) {
        let frameStart = dateFrameStart
        let frameEnd = dateFrameEnd
        self.mayAddRandomDate(possibleDates, frameStart: frameStart, frameEnd: frameEnd)
    }
    
    func createCandidateDates() -> Dictionary<NSDate, Double> {
        var candiDates = Dictionary<NSDate, Double>()
        let masterList = MasterList.sharedInstance
        for day in 0..<_daysInFourWeeks {
            let newDate = flattenDate(NSDate(timeInterval: _secondsInDay * Double(day), sinceDate: dateFrameStart))
            if (masterList.validDate(newDate) && self.validDate(newDate)) {
                candiDates[newDate] = 1
            } else {
                candiDates[newDate] = 0
            }
        }
        return candiDates
    }
    
    func validDate(date: NSDate) -> Bool {
        let day = MasterList.Day(date: date)
        return self.validDays[day]!
    }
    
    func mayAddRandomDate(possibleDates: Dictionary<NSDate, Double>, frameStart: NSDate, frameEnd: NSDate) {
        // Find whether there is a date in the frame that has already passed or is today. In this case, leave it alone
        self.completeRefresh = self.completeRefresh || self.dates.count == 0
        var i = 0
        var needToReplace = false
        while i < self.dates.count {
            // if the if condition is never met, then the date is in the past and should not be reset
            if (self.dates[i].compare(flattenDate(NSDate())) == .OrderedDescending && self.dates[i].compare(frameEnd) == .OrderedAscending && self.dates[i].compare(frameStart) == .OrderedDescending) {
                // The date is still to come, and we need to replace it
                self.dates.removeAtIndex(i)
                needToReplace = true
                i -= 1
            }
            i += 1
        }
        // Allows us to force date filling when the dateframe is updated
        if needToReplace || self.completeRefresh {
            // Use the updated frame start, which is the later of today or the frame start passed into the function
            var updatedFrameStart = self.flattenDate(NSDate())
            if frameStart.compare(updatedFrameStart) == .OrderedDescending {
                updatedFrameStart = frameStart
            }
            // create the new set of dates that we may populate
            let updatedPossibleDates = self.datesInFrame(possibleDates, frameStart: updatedFrameStart, frameEnd: frameEnd)
            let newSelectedDate = self.selectDate(updatedPossibleDates)
            // Add the new randomly selected date
            self.dates.append(newSelectedDate)
        }
    }
    
    func datesInFrame(possibleDates: Dictionary<NSDate, Double>, frameStart: NSDate, frameEnd: NSDate) -> Dictionary<NSDate, Double> {
        var dates = Dictionary<NSDate, Double>()
        // send possibleDates, an array, and the dateframe
        for (date, distribution) in possibleDates {
            if (date.compare(frameStart) == NSComparisonResult.OrderedSame || date.compare(frameStart) == NSComparisonResult.OrderedDescending) &&
                (date.compare(frameEnd) == NSComparisonResult.OrderedSame || date.compare(frameEnd) == NSComparisonResult.OrderedAscending) {
                    dates[date] = distribution
            }
        }
        return dates
    }
    
    func selectDate(dateGroup: Dictionary<NSDate, Double>) -> NSDate {
        var total = 0.0
        var selection: NSDate?
        for (_, distribution) in dateGroup {
            total += distribution
        }
        var rand = Double.random(min: 0.0, max: total)
        for (date, distribution) in dateGroup {
            if (selection == nil) {
                rand -= distribution
                if (rand < 0) {
                    selection = date
                }
            }
        }
        return selection!
    }
    
    func flattenDate(date: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([NSCalendarUnit.Weekday, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Year], fromDate: date)
        return calendar.dateFromComponents(components)!
    }
    
    func mayUpdateDaySelections(newSelections: Dictionary<MasterList.Day, Bool>) {
        var updateNeeded: Bool = false
        let masterList = MasterList.sharedInstance
        let masterListDays = masterList.getDaySelections()
        for (day, bool) in newSelections {
            if masterListDays[day]! {
                if bool != self.validDays[day] {
                    updateNeeded = true
                }
            }
        }
        if updateNeeded {
            self.updateDaySelections(newSelections)
            self.refreshDates()
        }
    }
    
    // Converts the dictionary into the array to be stored in the PFUser, since PFUser dictionaries cannot store Day enums. Then calls
    func updateDaySelections(selections: Dictionary<MasterList.Day, Bool>) {
        self.validDays = selections
        self.updateDaySelections(self.convertDictionaryToBoolArray(selections))
    }
    
    func updateDaySelections(selections: [Bool]) {
        self.saveObject["validDays"] = selections
        self.save()
    }
        
    func recordPrayed(date: NSDate) {
        var alreadyIn = false
        let flattenedDate = flattenDate(date)
        for item in self.prayerRecord {
            if flattenedDate.compare(item) == .OrderedSame {
                alreadyIn = true
            }
        }
        if !alreadyIn {
            self.prayerRecord.append(flattenDate(date))
        }
        self.save()
    }
    
    func removePrayed(date: NSDate) {
        let flattenedDate = flattenDate(date)
        for i in 0..<self.prayerRecord.count {
            if flattenedDate.compare(self.prayerRecord[i]) == .OrderedSame {
                self.prayerRecord.removeAtIndex(i)
            }
        }
        self.save()
    }
    
    func doneToday() -> Bool {
        var isDone = false
        let today = flattenDate(NSDate())
        for date in self.prayerRecord {
            if date.compare(today) == .OrderedSame {
                isDone = true
            }
        }
        return isDone
    }
    
    func getValidDays() -> Dictionary<MasterList.Day, Bool> {
        return self.validDays
    }
    
}