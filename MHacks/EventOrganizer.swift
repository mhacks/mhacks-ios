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
        
        let calendar = NSCalendar.sharedCalendar
        
        startDate = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: firstDate, options: [])!
        endDate = calendar.nextDateAfterDate(firstDate, matchingUnit: .Hour, value: 0, options: .MatchNextTime)!
        
        var hours = [Hour(startDate: calendar.dateBySettingHour(calendar.component(.Hour, fromDate: firstDate), minute: 0, second: 0, ofDate: firstDate, options: [])!)]
        
        let stopDate = endDate.earlierDate(lastDate)
        
        calendar.enumerateDatesStartingAfterDate(firstDate, matchingComponents: Hour.Components, options: .MatchNextTime) { date, exactMatch, stop in
			guard let date = date
			else
			{
				return
			}
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
        
        return hours.reduce(0.0) { partial, hour in
            return partial + hour.partialForDate(date)
        }
    }
    
    func partialHoursFromDate(fromDate: NSDate, toDate: NSDate) -> HalfOpenInterval<Double> {
        return partialHourForDate(fromDate)..<partialHourForDate(toDate)
    }
    
    static let weekdayFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("EEEE", options: 0, locale: NSLocale.autoupdatingCurrentLocale())
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
        return NSCalendar.sharedCalendar.nextDateAfterDate(startDate, matchingUnit: .Minute, value: 0, options: .MatchNextTime)!
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
        formatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("hh a", options: 0, locale: NSLocale.autoupdatingCurrentLocale())
        return formatter
    }()
    
    var title: String {
        return Hour.Formatter.stringFromDate(startDate)
    }
}

@objc final class EventOrganizer : NSObject {
    
    // MARK: Initialization
    
    init(events theEvents: [Event]) {
        
        // Return if no events
        guard !theEvents.isEmpty
		else
		{
			self.days = []
			self.eventsByDay = []
			
			self.partialHoursByDay = []
			
			self.numberOfColumnsByDay = []
			self.columnsByDay = []
			return
		}
		let events = theEvents.sort { $0.0.startDate < $0.1.startDate }
		
        // First and last date
        let firstDate = events.first!.startDate
        
        let lastDate = events.reduce(NSDate.distantPast() ) { lastDate, event in
            return lastDate.laterDate(event.endDate)
        }
        
        // Calendar
        
        let calendar = NSCalendar.sharedCalendar
        
        // Get first day
        
        var days = [Day(firstDate: firstDate, lastDate: lastDate)]
        
        calendar.enumerateDatesStartingAfterDate(firstDate, matchingComponents: Day.Components, options: .MatchNextTime) { date, exactMatch, stop in
			guard let date = date
			else
			{
				return
			}
            if date < lastDate {
                days += [Day(firstDate: date, lastDate: lastDate)]
            } else {
                stop.initialize(true)
            }
        }
        
        self.days = days
        
        // Events
        
        self.eventsByDay = days.map { day in
            return events.filter { event in
                return conflicts(day, timeInterval2: event)
            }
        }
        
        // Partial hours
        
        var partialHoursByDay: [[HalfOpenInterval<Double>]] = []
        
        for day in 0..<days.count {
            partialHoursByDay += [self.eventsByDay[day].map { event in
                return days[day].partialHoursFromDate(event.startDate, toDate: event.endDate)
            }]
        }
        
        self.partialHoursByDay = partialHoursByDay
        
        // Conflicts
        
        var numberOfColumnsByDay: [[Int]] = []
        var columnsByDay: [[Int]] = []
        
        for day in 0..<partialHoursByDay.count {
            
            let partialHoursCount = partialHoursByDay[day].count
            
            var column = 0
            
            var numberOfColumns = Array(count: partialHoursCount, repeatedValue: 1)
            var columns = Array(count: partialHoursCount, repeatedValue: 0)
            
            for index in 0..<partialHoursCount {
				
                columns[index] = column
                
                if (index + 1 < partialHoursCount) && partialHoursByDay[day][index].overlaps(partialHoursByDay[day][index+1]) {
                    
                    column += 1
                    
                } else {
                    
                    numberOfColumns[(index-column)...index] = ArraySlice(count: column+1, repeatedValue: column+1)
                    
                    column = 0
                }
            }
            
            numberOfColumnsByDay += [numberOfColumns]
            columnsByDay += [columns]
        }
        
        self.numberOfColumnsByDay = numberOfColumnsByDay
        self.columnsByDay = columnsByDay
    }
    
    // MARK: Days and Hours
    
    let days: [Day]
    
    // MARK: Events
    
    private let eventsByDay: [[Event]]
    
    func numberOfEventsInDay(day: Int) -> Int {
        return eventsByDay[day].count
    }
    
    func eventAtIndex(index: Int, inDay day: Int) -> Event {
        return eventsByDay[day][index]
    }
    
    func findDayAndIndexForEventWithID(ID: String) -> (day: Int, index: Int)? {
        
        for day in 0..<eventsByDay.count {
            
            let IDs = eventsByDay[day].map { $0.ID }
            
            if let index = IDs.indexOf(ID) {
                return (day, index)
            }
        }
        
        return nil
    }
    
    // MARK: Partial hours
    
    private let partialHoursByDay: [[HalfOpenInterval<Double>]]
    
    func partialHoursForEventAtIndex(index: Int, inDay day: Int) -> HalfOpenInterval<Double> {
        return partialHoursByDay[day][index]
    }
    
    // MARK: Columns
    
    private let numberOfColumnsByDay: [[Int]]
    private let columnsByDay: [[Int]]
    
    func numberOfColumnsForEventAtIndex(index: Int, inDay day: Int) -> Int {
        return numberOfColumnsByDay[day][index]
    }
    
    func columnForEventAtIndex(index: Int, inDay day: Int) -> Int {
        return columnsByDay[day][index]
    }
	
	@objc convenience init?(serialized: Serialized) {
		guard let eventsJSON = serialized["results"] as? [[String: AnyObject]]
		else {
			return nil
		}
		self.init(events: eventsJSON.flatMap { Event(JSON: $0) })
	}
	private static let eventsKey = "events"
}
extension EventOrganizer: JSONCreateable, NSCoding  {
	
	var allEvents : [Event] {
		return eventsByDay.flatten().map { $0 }
	}
	
	var next5Events : [Event] {
		let today = NSDate(timeIntervalSinceNow: 0)
		var startIndex = 0
		let events = allEvents
		// we could use binary search here but its too much work with little benefit
		for (i, event) in events.enumerate()
		{
			// Keep going while the event's start date is less than today
			guard event.startDate < today
			else
			{
				startIndex = i
				break
			}
		}
		return Array(events[startIndex..<min(startIndex + 5, events.count)])
	}
	
	@objc func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(allEvents as NSArray, forKey: EventOrganizer.eventsKey)
	}
	
	@objc convenience init?(coder aDecoder: NSCoder) {
		guard let events = aDecoder.decodeObjectForKey(EventOrganizer.eventsKey) as? [Event]
		else
		{
			return nil
		}
		self.init(events: events)
	}
}
