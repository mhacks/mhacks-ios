//
//  EventManager.swift
//  MHacks
//
//  Created by Russell Ladd on 9/30/14.
//  Copyright (c) 2014 GRL5. All rights reserved.
//

import Foundation

struct Event {
    
    let name: String
    let category: String
    let location: String
    let startDate: NSDate
    let endDate: NSDate
    let description: String
}

extension Event {
    
    static let dateIntervalFormatter = NSDateIntervalFormatter()
    
    var title: String {
        return name
    }
    
    var subtitle: String {
        return Event.dateIntervalFormatter.stringFromDate(startDate, toDate: endDate)
    }
}

class EventManager {
    
    var events: [Event]
    
    init() {
        
        let startDate = NSDate()
        let endDate = NSDate(timeIntervalSinceNow: 3600.0)
        
        let description = "Description lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis gravida sit amet lacus at rhoncus. Pellentesque tortor quam, tempor vitae nunc eget, semper ullamcorper augue. Maecenas vulputate tortor ut tempus sagittis. Pellentesque nec mi at ex feugiat pharetra. Donec pharetra risus at mauris efficitur, at efficitur odio maximus. Etiam a."
        
        events = [
            Event(name: "Registration", category: "Special Events", location: "EECS", startDate: startDate , endDate: endDate, description: description)
        ]
    }
}
