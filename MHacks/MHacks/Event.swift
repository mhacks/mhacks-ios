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
    let locations: [Location]
    let startDate: NSDate
    let duration: NSTimeInterval
    let description: String
    
    var endDate: NSDate {
        return startDate.dateByAddingTimeInterval(duration)
    }
    
    var locationsDescription: String {
        switch locations.count {
        case 1:
            return locations[0].name
        case 2:
            return "\(locations[0].name) & \(locations[1].name)"
        default:
            return locations.reduce("") { $0 + ", " + $1.name }
        }
    }
}

extension Event: Fetchable {
    
    init?(object: PFObject) {
        
        let name = object["title"] as? String
        let categoryObject = object["category"] as? PFObject
        let locationObjects = object["locations"] as? [PFObject]
        let startDate = object["startTime"] as? NSDate
        let duration = (object["duration"] as? NSNumber)?.doubleValue
        let description = object["details"] as? String
        
        if (name == nil || categoryObject == nil || locationObjects == nil || startDate == nil || duration == nil || description == nil) {
            return nil
        }
        
        let category = Category(object: categoryObject!)
        
        if (category == nil) {
            return nil
        }
        
        self.name = name!
        self.category = category!
        self.locations = locationObjects!.map { Location(object: $0)! }//.filter { $0 != nil }.map { $0! }
        self.startDate = startDate!
        self.duration = duration!
        self.description = description!
    }
}
