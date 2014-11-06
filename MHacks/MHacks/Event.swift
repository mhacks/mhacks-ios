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
    let category: Category
    let location: String
    let startDate: NSDate
    let duration: NSTimeInterval
    let description: String
    
    var endDate: NSDate {
        return startDate.dateByAddingTimeInterval(duration)
    }
    
    init?(object: PFObject) {
        
        let name = object["title"] as? String
        let categoryObject = object["category"] as? PFObject
        let startDate = object["startTime"] as? NSDate
        let duration = (object["duration"] as? NSNumber)?.doubleValue
        let description = object["details"] as? String
        
        if (name == nil || startDate == nil || duration == nil || description == nil || categoryObject == nil) {
            return nil
        }
        
        let category = Category(object: categoryObject!)
        
        if (category == nil) {
            return nil
        }
        
        self.name = name!
        self.category = category!
        self.location = ""
        self.startDate = startDate!
        self.duration = duration!
        self.description = description!
    }
    
    enum Result {
        case Success([Event])
        case Error(NSError?)
    }
    
    static func fetchEvents(completionHandler: Result -> Void) {
        
        let query = PFQuery(className: "Event")
        
        query.includeKey("category")
        
        query.findObjectsInBackgroundWithBlock { objects, error in
            
            if let objects = objects as? [PFObject] {
                
                let events: [Event] = objects.map { Event(object: $0 ) }.filter { $0 != nil }.map { $0! }
                
                completionHandler(.Success(events))
                
            } else {
                
                completionHandler(.Error(error))
            }
        }
    }
}
