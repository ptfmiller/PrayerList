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
let _secondsInFourWeeks: NSTimeInterval = 27 * _secondsInDay // 27 days instead of 28 because we are inclusive on both sides
let _daysInWeek = 7
let _daysInFourWeeks = _daysInWeek * 4
let _firstDayOfWeek = 1
let _lastDayOfWeek = _daysInWeek


class PrayerRequest {
    enum Frequency: Int {
        case daily, weekly, biweekly, fourweekly
    }
    
    var requestName: String = ""
    var details: String? = ""
    var dateFrameStart: NSDate = NSDate()
    var dateFrameEnd: NSDate = NSDate()
    var dates: [NSDate] = []
    var frequency: Frequency = .weekly
    
    init(name: String, details: String?, frequency: Frequency) {
        requestName = name
        self.details = details
        
        let calendar = NSCalendar.currentCalendar()
        
        let startComponents = calendar.components(NSCalendarUnit.CalendarUnitWeekday | NSCalendarUnit.CalendarUnitWeekOfYear | NSCalendarUnit.CalendarUnitYear, fromDate: NSDate())
        startComponents.weekday = _firstDayOfWeek
        dateFrameStart = flattenDate(calendar.dateFromComponents(startComponents)!)
        
        let endComponents = calendar.components(NSCalendarUnit.CalendarUnitWeekday | NSCalendarUnit.CalendarUnitWeekOfYear | NSCalendarUnit.CalendarUnitYear, fromDate: NSDate(timeIntervalSinceNow: _secondsInFourWeeks))
        endComponents.weekday = _lastDayOfWeek
        dateFrameEnd = flattenDate(calendar.dateFromComponents(endComponents)!)
        
        self.frequency = frequency
        refreshDates()
    }
    
    func refreshDates() {
        dates = []
        let masterList = MasterList.sharedInstance
        let calendarList = masterList.calendarList
        var possibleDates = candidateDates()
        
        // perform weighting based on calendarList's fullness
        for (date, distribution) in possibleDates {
            if (calendarList[date] != nil) {possibleDates.updateValue(possibleDates[date]! * pow(0.5, Double(calendarList[date]!.count)), forKey: date)}
        }
        
        switch frequency {
        case .daily:
            for (date, distribution) in possibleDates {
                if (distribution > 0) {
                    dates.append(date)
                }
            }
        case .weekly:
            // First week
            var frameStart = dateFrameStart
            var frameEnd = flattenDate(NSDate(timeInterval: _secondsInDay * Double(_daysInWeek - 1), sinceDate: dateFrameStart))
            var weeksDates = datesInFrame(possibleDates, frameStart: frameStart, frameEnd: frameEnd)
            dates.append(selectDate(weeksDates))
            
            // Second week
            frameStart = flattenDate(NSDate(timeInterval: _secondsInDay * Double(_daysInWeek), sinceDate: dateFrameStart))
            frameEnd = flattenDate(NSDate(timeInterval: _secondsInDay * Double(_daysInWeek * 2 - 1), sinceDate: dateFrameStart))
            weeksDates = datesInFrame(possibleDates, frameStart: frameStart, frameEnd: frameEnd)
            dates.append(selectDate(weeksDates))
            
            // Third week
            frameStart = flattenDate(NSDate(timeInterval: _secondsInDay * Double(_daysInWeek * 2), sinceDate: dateFrameStart))
            frameEnd = flattenDate(NSDate(timeInterval: _secondsInDay * Double(_daysInWeek * 3 - 1), sinceDate: dateFrameStart))
            weeksDates = datesInFrame(possibleDates, frameStart: frameStart, frameEnd: frameEnd)
            dates.append(selectDate(weeksDates))
            
            // Fourth week
            frameStart = flattenDate(NSDate(timeInterval: _secondsInDay * Double(_daysInWeek * 3), sinceDate: dateFrameStart))
            frameEnd = dateFrameEnd
            weeksDates = datesInFrame(possibleDates, frameStart: frameStart, frameEnd: frameEnd)
            dates.append(selectDate(weeksDates))
            
        case .biweekly:
            // First fortnight
            var frameStart = dateFrameStart
            var frameEnd = flattenDate(NSDate(timeInterval: _secondsInDay * Double(_daysInWeek * 2 - 1), sinceDate: dateFrameStart))
            var weeksDates = datesInFrame(possibleDates, frameStart: frameStart, frameEnd: frameEnd)
            dates.append(selectDate(weeksDates))
            
            // Second fortnight
            frameStart = flattenDate(NSDate(timeInterval: _secondsInDay * Double(_daysInWeek * 2), sinceDate: dateFrameStart))
            frameEnd = dateFrameEnd
            weeksDates = datesInFrame(possibleDates, frameStart: frameStart, frameEnd: frameEnd)
            dates.append(selectDate(weeksDates))
            
        case .fourweekly:
            var frameStart = dateFrameStart
            var frameEnd = dateFrameEnd
            var weeksDates = datesInFrame(possibleDates, frameStart: frameStart, frameEnd: frameEnd)
            dates.append(selectDate(weeksDates))
        }
    }
    
    
    func candidateDates() -> Dictionary<NSDate, Double> {
        var candiDates = Dictionary<NSDate, Double>()
        let masterList = MasterList.sharedInstance
        for day in 0..<_daysInFourWeeks {
            var newDate = flattenDate(NSDate(timeInterval: _secondsInDay * Double(day), sinceDate: dateFrameStart))
            if (masterList.validDate(newDate)) {
                candiDates[newDate] = 1
            } else {
                candiDates[newDate] = 0
            }
        }
        return candiDates
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
        for (date, distribution) in dateGroup {
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
        let components = calendar.components(NSCalendarUnit.CalendarUnitWeekday | NSCalendarUnit.CalendarUnitWeekOfYear | NSCalendarUnit.CalendarUnitYear, fromDate: date)
        return calendar.dateFromComponents(components)!
    }
}