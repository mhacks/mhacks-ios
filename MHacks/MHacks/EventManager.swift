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
        
        Parse.setApplicationId(Keys.sharedKeys.parseApplicationID, clientKey: Keys.sharedKeys.parseClientKey)
        
        let query = PFQuery(className: "Event")
        
        let results = query.findObjects() as [PFObject]
        
        events = results.map { object in
            
            let name = object["title"] as String
            let startDate = object["startTime"] as NSDate
            let duration = (object["duration"] as NSNumber).doubleValue
            let description = object["details"] as String
            
            println(NSDateFormatter.localizedStringFromDate(startDate, dateStyle: .ShortStyle, timeStyle: .ShortStyle))
            
            return Event(name: name, category: "", location: "", startDate: startDate, duration: duration, description: description)
        }
        
        /*
        let hour = calendar.component(.CalendarUnitHour, fromDate: NSDate())
        var date = calendar.dateBySettingHour(hour, minute: 0, second: 0, ofDate: NSDate(), options: nil)
        
        let description = "Description lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis gravida sit amet lacus at rhoncus. Pellentesque tortor quam, tempor vitae nunc eget, semper ullamcorper augue. Maecenas vulputate tortor ut tempus sagittis. Pellentesque nec mi at ex feugiat pharetra. Donec pharetra risus at mauris efficitur, at efficitur odio maximus. Etiam a."
        
        events = map(0..<6) { index in
            
            let startDate = date
            date = calendar.dateByAddingUnit(.CalendarUnitHour, value: 2, toDate: date, options: nil)
            
            return Event(name: "Registration", category: "Special Events", location: "EECS", startDate: startDate , duration: 7200.0, description: description)
        }*/
    }
}
