//
//  Event.swift
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
    
    enum Result {
        case Success([Event])
        case Error(NSError?)
    }
    
    static func fetchEvents(completionHandler: Result -> Void) {
        
        let query = PFQuery(className: "Event")
        
        query.findObjectsInBackgroundWithBlock { objects, error in
            
            if let objects = objects {
                
                let events: [Event] = objects.map { object in
                    
                    let name = object["title"] as String
                    let startDate = object["startTime"] as NSDate
                    let duration = (object["duration"] as NSNumber).doubleValue
                    let description = object["details"] as String
                    
                    // FIXME: Gracefully fail if object data is malformed
                    
                    return Event(name: name, category: "", location: "", startDate: startDate, duration: duration, description: description)
                }
                
                completionHandler(.Success(events))
                
            } else {
                
                completionHandler(.Error(error))
            }
        }
    }
}
