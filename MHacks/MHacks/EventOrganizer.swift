//
//  EventOrganizer.swift
//  MHacks
//
//  Created by Russell Ladd on 10/3/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

class EventOrganizer {
    
    // MARK: Initialization
    
    init(events: [Event]) {
        
        assert(!events.isEmpty, "You cannot pass an empty array of events")
        
        // First and last date
        
        let firstDate = events.reduce(NSDate.distantFuture() as NSDate) { firstDate, event in
            return firstDate.earlierDate(event.startDate)
        }
        
        let lastDate = events.reduce(NSDate.distantPast() as NSDate) { lastDate, event in
            return lastDate.laterDate(event.endDate)
        }
        
        // Calendar
        
        let calendar = NSCalendar.currentCalendar()
        
        // Components
        
        let dayComponents = NSDateComponents()
        dayComponents.hour = 0
        
        let hourComponents = NSDateComponents()
        hourComponents.minute = 0
        
        // Hour function
        
        let hoursForDate: (NSDate) -> [NSDate] = { date in
            
            var hours = [calendar.dateBySettingHour(calendar.component(.CalendarUnitHour, fromDate: date), minute: 0, second: 0, ofDate: date, options: nil)]
            
            let nextDayDate = calendar.nextDateAfterDate(date, matchingComponents: dayComponents, options: .MatchNextTime)!
            let stopDate = nextDayDate.earlierDate(lastDate)
            
            calendar.enumerateDatesStartingAfterDate(date, matchingComponents: hourComponents, options: .MatchNextTime) { date, exactMatch, stop in
                
                if date.timeIntervalSinceReferenceDate < stopDate.timeIntervalSinceReferenceDate {
                    hours += [date]
                } else {
                    stop.initialize(true)
                }
            }
            
            return hours
        }
        
        // Get first day and hours
        
        var days = [calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: firstDate, options: nil)]
        var hours = [hoursForDate(firstDate)]
        
        // Get rest of days and hours
        
        calendar.enumerateDatesStartingAfterDate(firstDate, matchingComponents: dayComponents, options: .MatchNextTime) { date, exactMatch, stop in
            
            if date.timeIntervalSinceReferenceDate < lastDate.timeIntervalSinceReferenceDate {
                days += [date]
                hours += [hoursForDate(date)]
            } else {
                stop.initialize(true)
            }
        }
        
        self.days = days
        self.hours = hours
        
        // Events
        
        self.eventsByDay = days.map { dayDate in
            return events.filter { event in
                return calendar.isDate(dayDate, inSameDayAsDate: event.startDate)
            }
        }
    }
    
    // MARK: Events
    
    private let eventsByDay: [[Event]]
    
    func numberOfEventsInDay(day: Int) -> Int {
        return eventsByDay[day].count
    }
    
    func eventAtIndex(index: Int, inDay day: Int) -> Event {
        return eventsByDay[day][index]
    }
    
    private func durationInHoursForTimeInterval(timeInterval: NSTimeInterval) -> Double {
        return timeInterval / 3600.0
    }
    
    func startHourForEventAtIndex(index: Int, inDay day: Int) -> Double {
        return durationInHoursForTimeInterval(eventsByDay[day][index].startDate.timeIntervalSinceDate(hours[day].first!))
    }
    
    func durationInHoursForEventAtIndex(index: Int, inDay day: Int) -> Double {
        return durationInHoursForTimeInterval(eventsByDay[day][index].duration)
    }
    
    // MARK: Days and Hours
    
    private let days: [NSDate]
    private let hours: [[NSDate]]
    
    func numberOfDays() -> Int {
        return days.count
    }
    
    func numberOfHoursInDay(day: Int) -> Int {
        return hours[day].count
    }
    
    // MARK: Presentation
    
    private struct Formatter {
        
        static let Weekday: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("EEEE", options: 0, locale: nil)
            return formatter
            }()
        
        static let Hour: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("hh a", options: 0, locale: nil)
            return formatter
            }()
    }
    
    func titleForDay(day: Int) -> String {
        return Formatter.Weekday.stringFromDate(days[day])
    }
    
    func titleForHour(hour: Int, inDay day: Int) -> String {
        return Formatter.Hour.stringFromDate(hours[day][hour])
    }

}
