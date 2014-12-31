//
//  EventOrganizer.swift
//  MHacks
//
//  Created by Russell Ladd on 10/3/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

protocol TimeInterval {
    
    var timeInterval: HalfOpenInterval<NSTimeInterval> { get }
}

func conflicts(timeInterval1: TimeInterval, timeInterval2: TimeInterval) -> Bool {
    return !timeInterval1.timeInterval.clamp(timeInterval2.timeInterval).isEmpty
}

extension Event: TimeInterval {
    
    var timeInterval: HalfOpenInterval<NSTimeInterval> {
        return startDate.timeIntervalSinceReferenceDate..<endDate.timeIntervalSinceReferenceDate
    }
}

struct Day: TimeInterval {
    
    // Creates a day containing firstDate
    // Clamps hours to firstDate and lastDate
    init(firstDate: NSDate, lastDate: NSDate) {
        
        let calendar = NSCalendar.currentCalendar()
        
        startDate = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: firstDate, options: nil)!
        endDate = calendar.nextDateAfterDate(firstDate, matchingUnit: .CalendarUnitHour, value: 0, options: .MatchNextTime)!
        
        var hours = [Hour(startDate: calendar.dateBySettingHour(calendar.component(.CalendarUnitHour, fromDate: firstDate), minute: 0, second: 0, ofDate: firstDate, options: nil)!)]
        
        let stopDate = endDate.earlierDate(lastDate)
        
        calendar.enumerateDatesStartingAfterDate(firstDate, matchingComponents: Hour.Components, options: .MatchNextTime) { date, exactMatch, stop in
            
            if date.timeIntervalSinceReferenceDate < stopDate.timeIntervalSinceReferenceDate {
                hours += [Hour(startDate: date)]
            } else {
                stop.initialize(true)
            }
        }
        
        self.hours = hours
    }
    
    // The first moment of the day
    let startDate: NSDate
    
    // The last moment of the day
    let endDate: NSDate
    
    static let Components: NSDateComponents = {
        let components = NSDateComponents()
        components.hour = 0;
        return components
    }()
    
    var timeInterval: HalfOpenInterval<NSTimeInterval> {
        return startDate.timeIntervalSinceReferenceDate..<endDate.timeIntervalSinceReferenceDate
    }
    
    let hours: [Hour]
    
    func partialHourForDate(date: NSDate) -> Double {
        
        return reduce(hours, 0.0) { partial, hour in
            return partial + hour.partialForDate(date)
        }
    }
    
    func partialHoursFromDate(fromDate: NSDate, toDate: NSDate) -> HalfOpenInterval<Double> {
        return partialHourForDate(fromDate)..<partialHourForDate(toDate)
    }
    
    static let weekdayFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("EEEE", options: 0, locale: nil)
        return formatter
    }()
    
    var weekdayTitle: String {
        return Day.weekdayFormatter.stringFromDate(startDate)
    }
    
    var dateTitle: String {
        return NSDateFormatter.localizedStringFromDate(startDate, dateStyle: .ShortStyle, timeStyle: .NoStyle)
    }
}

struct Hour: TimeInterval {
    
    let startDate: NSDate
    
    var endDate: NSDate {
        return NSCalendar.currentCalendar().nextDateAfterDate(startDate, matchingUnit: .CalendarUnitMinute, value: 0, options: .MatchNextTime)!
    }
    
    var duration: NSTimeInterval {
        return endDate.timeIntervalSinceReferenceDate - startDate.timeIntervalSinceReferenceDate
    }
    
    func partialForDate(date: NSDate) -> Double {
        
        let dateMoment = (date.timeIntervalSinceReferenceDate - startDate.timeIntervalSinceReferenceDate) / duration
        let dateInterval = dateMoment..<dateMoment
        
        let hourInterval = 0.0..<1.0
        
        return hourInterval.clamp(dateInterval).start
    }
    
    static let Components: NSDateComponents = {
        let components = NSDateComponents()
        components.minute = 0;
        return components
    }()
    
    var timeInterval: HalfOpenInterval<NSTimeInterval> {
        return startDate.timeIntervalSinceReferenceDate..<endDate.timeIntervalSinceReferenceDate
    }
    
    static let Formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("hh a", options: 0, locale: nil)
        return formatter
    }()
    
    var title: String {
        return Hour.Formatter.stringFromDate(startDate)
    }
}

class EventOrganizer {
    
    // MARK: Initialization
    
    init(events: [Event]) {
        
        // Return if no events
        
        if (events.isEmpty) {
            return
        }
        
        // First and last date
        
        let firstDate = events.reduce(NSDate.distantFuture() as NSDate) { firstDate, event in
            return firstDate.earlierDate(event.startDate)
        }
        
        let lastDate = events.reduce(NSDate.distantPast() as NSDate) { lastDate, event in
            return lastDate.laterDate(event.endDate)
        }
        
        // Calendar
        
        let calendar = NSCalendar.currentCalendar()
        
        // Get first day
        
        var days = [Day(firstDate: firstDate, lastDate: lastDate)]
        
        calendar.enumerateDatesStartingAfterDate(firstDate, matchingComponents: Day.Components, options: .MatchNextTime) { date, exactMatch, stop in
            
            if date.timeIntervalSinceReferenceDate < lastDate.timeIntervalSinceReferenceDate {
                days += [Day(firstDate: date, lastDate: lastDate)]
            } else {
                stop.initialize(true)
            }
        }
        
        self.days = days
        
        // Events
        
        self.eventsByDay = days.map { day in
            return events.filter { event in
                return conflicts(day, event)
            }
        }
        
        // Partial hours
        
        var partialHours: [[HalfOpenInterval<Double>]] = []
        
        for day in 0..<days.count {
            partialHours += [self.eventsByDay[day].map { event in
                return days[day].partialHoursFromDate(event.startDate, toDate: event.endDate)
            }]
        }
        
        self.partialHours = partialHours
    }
    
    // MARK: Events
    
    private let eventsByDay: [[Event]] = []
    
    func numberOfEventsInDay(day: Int) -> Int {
        return eventsByDay[day].count
    }
    
    func eventAtIndex(index: Int, inDay day: Int) -> Event {
        return eventsByDay[day][index]
    }
    
    // MARK: Partial hours
    
    private let partialHours: [[HalfOpenInterval<Double>]] = []
    
    func partialHoursForEventAtIndex(index: Int, inDay day: Int) -> HalfOpenInterval<Double> {
        return partialHours[day][index]
    }
    
    // MARK: Days and Hours
    
    let days: [Day] = []
    
    // MARK: Empty
    
    var isEmpty: Bool {
        return days.count == 0
    }
}
