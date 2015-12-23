//
//  Event.swift
//  MHacks
//
//  Created by Russell Ladd on 9/30/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation
import UIKit


struct Event: Equatable {
 
	enum Category: String {
		// TODO: Fill
		case Test
		
		var color: UIColor {
			// FIXME: Implement
			return UIColor.redColor()
		}
	}
	
    let ID: String
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

extension Event : JSONCreateable {
	init?(JSON: [String : AnyObject]) {
		guard let name = JSON["name"] as? String, let categoryRaw = JSON["category"] as? String, let category = Category(rawValue: categoryRaw), let locationID = JSON["location"] as? String, let startDate = JSON["startTime"] as? NSTimeInterval, let duration = JSON["duration"] as? NSTimeInterval, let description = JSON["details"] as? String, let ID = JSON["id"] as? String
		else
		{
			return nil
		}
		self.ID = ID
		self.name = name
		self.category = category
		print(locationID)
		self.locations = [] // TODO: Fill me
		self.startDate = NSDate(timeIntervalSince1970: startDate)
		self.duration = duration
		self.description = description
	}
	
	func encodeWithCoder(aCoder: NSCoder) {
		// TODO: Implement me.
	}
	
	static var jsonKeys : [String] { return ["id", "name", "details", "category", "startTime", "duration"] }
}

func ==(lhs: Event, rhs: Event) -> Bool {
    
    return (lhs.ID == rhs.ID &&
        lhs.name == rhs.name &&
        lhs.category == rhs.category &&
        lhs.locations == rhs.locations &&
        lhs.startDate == rhs.startDate &&
        lhs.duration == rhs.duration &&
        lhs.description == rhs.description)
}
