//
//  EventManager.swift
//  MHacks
//
//  Created by Russell Ladd on 9/30/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

struct Event {
    
    let name: String
    let category: String
    let location: String
    let startDate: NSDate
    let duration: NSTimeInterval
    let description: String
    
    var endDate: NSDate {
        return startDate.dateByAddingTimeInterval(duration)
    }
}

class EventManager {
    
    var events: [Event]
    
    init() {
        
        let calendar = NSCalendar.currentCalendar()
        
        let hour = calendar.component(.CalendarUnitHour, fromDate: NSDate())
        var date = calendar.dateBySettingHour(hour, minute: 0, second: 0, ofDate: NSDate(), options: nil)
        
        let description = "Description lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis gravida sit amet lacus at rhoncus. Pellentesque tortor quam, tempor vitae nunc eget, semper ullamcorper augue. Maecenas vulputate tortor ut tempus sagittis. Pellentesque nec mi at ex feugiat pharetra. Donec pharetra risus at mauris efficitur, at efficitur odio maximus. Etiam a."
        
        events = map(0..<24) { index in
            
            let startDate = date
            date = calendar.dateByAddingUnit(.CalendarUnitHour, value: 1, toDate: date, options: nil)
            
            return Event(name: "Registration", category: "Special Events", location: "EECS", startDate: startDate , duration: 3600.0, description: description)
        }
    }
}
