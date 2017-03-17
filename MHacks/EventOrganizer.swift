//
//  EventOrganizer.swift
//  MHacks
//
//  Created by Russell Ladd on 10/3/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

extension Range {
    
    func containingInterval(_ other: Range) -> Range {
        return min(lowerBound, other.lowerBound)..<max(upperBound, other.upperBound)
    }
    
    mutating func formContainingInterval(_ other: Range) {
        self = containingInterval(other)
    }
}

struct Day {
    
    // Creates a day containing firstDate
    // Clamps hours to firstDate and lastDate
    init(firstDate: Date, lastDate: Date) {
        
        let calendar = Calendar.current
		
        startDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: firstDate)!
		
		// FIXME: Use the swift method instead?
        let nextDayDate = (calendar as NSCalendar).nextDate(after: firstDate, matching: .hour, value: 0, options: .matchNextTime)!
		
		let endDate = nextDayDate < lastDate ? nextDayDate : lastDate
		self.endDate = endDate
        
        var hours = [Hour(startDate: (calendar as NSCalendar).date(bySettingHour: (calendar as NSCalendar).component(.hour, from: firstDate), minute: 0, second: 0, of: firstDate, options: [])!)]

		// FIXME: Use the swift method instead?
        (calendar as NSCalendar).enumerateDates(startingAfter: firstDate, matching: Hour.Components, options: .matchNextTime) { date, exactMatch, stop in
			guard let date = date
			else
			{
				return
			}
            if date.timeIntervalSinceReferenceDate < endDate.timeIntervalSinceReferenceDate {
                hours += [Hour(startDate: date)]
            } else {
                stop.initialize(to: true)
            }
        }
        
        self.hours = hours
    }
    
    // The first moment of the day
    let startDate: Date
    
    // The last moment of the day
    let endDate: Date
    
    static let Components: DateComponents = {
        var components = DateComponents()
        components.hour = 0;
        return components
    }()
    
    var timeInterval: Range<TimeInterval> {
        return startDate.timeIntervalSinceReferenceDate..<endDate.timeIntervalSinceReferenceDate
    }
    
    let hours: [Hour]
    
    func partialHourForDate(_ date: Date) -> Double {
        
        return hours.reduce(0.0) { partial, hour in
            return partial + hour.partialForDate(date)
        }
    }
    
    func partialHoursFromDate(_ fromDate: Date, toDate: Date) -> Range<Double> {
        return partialHourForDate(fromDate)..<partialHourForDate(toDate)
    }
    
    static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE", options: 0, locale: NSLocale.autoupdatingCurrent)
        return formatter
    }()
    
    var weekdayTitle: String {
        return Day.weekdayFormatter.string(from: startDate)
    }
    
    var dateTitle: String {
        return DateFormatter.localizedString(from: startDate, dateStyle: .short, timeStyle: .none)
    }
}

struct Hour {
    
    let startDate: Date
	let endDate: Date
	
	init(startDate: Date) {
		self.startDate = startDate
		self.endDate = (Calendar.current as NSCalendar).nextDate(after: startDate, matching: .minute, value: 0, options: .matchNextTime)!
	}
	
    var duration: TimeInterval {
        return endDate.timeIntervalSinceReferenceDate - startDate.timeIntervalSinceReferenceDate
    }
    
    func partialForDate(_ date: Date) -> Double {
        
        let dateMoment = (date.timeIntervalSinceReferenceDate - startDate.timeIntervalSinceReferenceDate) / duration
        let dateInterval = dateMoment..<dateMoment
        
        let hourInterval = 0.0..<1.0
		
        return dateInterval.clamped(to: hourInterval).lowerBound
    }
    
    static let Components: DateComponents = {
        var components = DateComponents()
        components.minute = 0;
        return components
    }()
    
    var timeInterval: Range<TimeInterval> {
        return startDate.timeIntervalSinceReferenceDate..<endDate.timeIntervalSinceReferenceDate
    }
    
    static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "hh a", options: 0, locale: NSLocale.autoupdatingCurrent)
        return formatter
    }()
	
	static let minuteFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.setLocalizedDateFormatFromTemplate("hhmm")
		return formatter
	}()
	
    var title: String {
        return Hour.hourFormatter.string(from: startDate)
    }
}

final class EventOrganizer {
    
    // MARK: Initialization
	
    init(events: MHacksArray<Event>) {
        
        // Return if no events
        guard !events.isEmpty
		else {
			
			self.days = []
			self.eventsByDay = []
			
			self.partialHoursByDay = []
			
			self.numberOfColumnsByDay = []
			self.columnsByDay = []
			
			return
		}
		
        // First and last date
        let firstDate = events.first!.startDate
        
        let lastDate = events.reduce(Date.distantPast) { lastDate, event in
			return lastDate > event.endDate ? lastDate : event.endDate
        }
        
        // Calendar
        
        let calendar = Calendar.current
        
        // Get first day
        
        var days = [Day(firstDate: firstDate, lastDate: lastDate)]
        
        (calendar as NSCalendar).enumerateDates(startingAfter: firstDate, matching: Day.Components, options: .matchNextTime) { date, exactMatch, stop in
			
			guard let date = date else {
				return
			}
			
            if date < lastDate {
                days += [Day(firstDate: date, lastDate: lastDate)]
            } else {
                stop.initialize(to: true)
            }
        }
        
        self.days = days
        
        // Events
        
        self.eventsByDay = days.map { day in
            return events.filter { event in
                return day.timeInterval.overlaps(event.timeInterval)
            }
        }
        
        // Partial hours
        
        var partialHoursByDay: [[Range<Double>]] = []
        
        for day in 0..<days.count {
            partialHoursByDay += [self.eventsByDay[day].map { event in
                return days[day].partialHoursFromDate(event.startDate, toDate: event.endDate)
            }]
        }
        
        self.partialHoursByDay = partialHoursByDay
        
        // Overlaps
        
        var numberOfColumnsByDay: [[Int]] = []
        var columnsByDay: [[Int]] = []
        
        for (day, partialHours) in partialHoursByDay.enumerated() {
            
            var numberOfColumns = Array(repeating: 1, count: partialHours.count)
            var columns = Array(repeating: 0, count: partialHours.count)
            
            var currentOverlapGroup = 0..<0
            var currentOverlapInterval = 0.0..<0.0
			
            // This function breaks a conflicting group of events into columns
            // Uses the "meeting room" algorithm with an unlimited number of rooms (rooms = columns)
            func commitCurrentGroup() {
                
                guard !currentOverlapGroup.isEmpty else {
                    return
                }
                
                let partialHoursSlice = partialHours[currentOverlapGroup]
                
                var partialHourColumns = [[Range<TimeInterval>]]()
                
                for (partialHourIndex, partialHour) in zip(partialHoursSlice.indices, partialHoursSlice) {
                    
                    var placed = false
                    
                    for (columnIndex, partialHourColumn) in partialHourColumns.enumerated() {
                        
                        if !partialHourColumn.last!.overlaps(partialHour) {
                            
                            partialHourColumns[columnIndex].append(partialHour)
                            placed = true
                            
                            columns[partialHourIndex] = columnIndex
                            
                            break
                        }
                    }
                    
                    if (!placed) {
						
                        partialHourColumns.append([partialHour])
                        
                        columns[partialHourIndex] = partialHourColumns.count - 1
                    }
                }
                
                // All events in a group share the same number of columns
                numberOfColumns.replaceSubrange(currentOverlapGroup, with: Array(repeating: partialHourColumns.count, count: currentOverlapGroup.count))
            }
            
            // Detect and commit one group of conflicting events at a time
            for index in 0..<partialHours.count {
                
                let partialHour = partialHours[index]
                
                if !partialHour.overlaps(currentOverlapInterval) {
                    
                    commitCurrentGroup()
					
                    currentOverlapGroup = currentOverlapGroup.upperBound..<currentOverlapGroup.upperBound
                    currentOverlapInterval = partialHour
                }
                
                currentOverlapGroup = currentOverlapGroup.lowerBound..<(currentOverlapGroup.upperBound + 1)
                currentOverlapInterval.formContainingInterval(partialHour)
            }
            
            commitCurrentGroup()
            
            numberOfColumnsByDay += [numberOfColumns]
            columnsByDay += [columns]
        }
        
        self.numberOfColumnsByDay = numberOfColumnsByDay
        self.columnsByDay = columnsByDay
    }
    
    // MARK: Days and Hours
    
    let days: [Day]
    
    // MARK: Events
    
    fileprivate let eventsByDay: [[Event]]
    
    func numberOfEventsInDay(_ day: Int) -> Int {
        return eventsByDay[day].count
    }
    
    func eventAtIndex(_ index: Int, inDay day: Int) -> Event {
        return eventsByDay[day][index]
    }
    
    // MARK: Partial hours
    
    fileprivate let partialHoursByDay: [[Range<Double>]]
    
    func partialHoursForEventAtIndex(_ index: Int, inDay day: Int) -> Range<Double> {
        return partialHoursByDay[day][index]
    }
    
    // MARK: Columns
    
    fileprivate let numberOfColumnsByDay: [[Int]]
    fileprivate let columnsByDay: [[Int]]
    
    func numberOfColumnsForEventAtIndex(_ index: Int, inDay day: Int) -> Int {
        return numberOfColumnsByDay[day][index]
    }
    
    func columnForEventAtIndex(_ index: Int, inDay day: Int) -> Int {
        return columnsByDay[day][index]
    }
	
	// MARK: Helper
	
	func dayAndPartialHourForDate(_ date: Date) -> (day: Int, partialHour: Double)? {
		
		let possibleDay = days.index {
			return $0.timeInterval.contains(date.timeIntervalSinceReferenceDate)
		}
		
		guard let day = possibleDay else {
			return nil
		}
		
		return (day, days[day].partialHourForDate(date))
	}
}

extension EventOrganizer {
	
	var allEvents : [Event] {
		return eventsByDay.lazy.joined().map { $0 }
	}
	
	var next5Events : [Event] {
		let today = Date(timeIntervalSinceNow: 0)
		var startIndex = 0
		let events = allEvents
		// we could use binary search here but its too much work with little benefit
		for (i, event) in events.enumerated()
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
}
