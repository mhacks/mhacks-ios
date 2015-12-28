//
//  Event.swift
//  MHacks
//
//  Created by Russell Ladd on 9/30/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation
import UIKit


final class Event: Equatable {
 
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
//  let category: Category
    var locations: [Location]
    let startDate: NSDate
    let endDate: NSDate
    let description: String
	
	init(ID: String, name: String, locations: [Location], startDate: NSDate, endDate: NSDate, description: String) {
		self.ID = ID
		self.name = name
		self.locations = locations
		self.startDate = startDate
		self.endDate = endDate
		self.description = description
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
	convenience init?(JSON: [String : AnyObject]) {
		guard let name = JSON["name"] as? String/*, let categoryRaw = JSON["category"] as? String, let category = Category(rawValue: categoryRaw)*/, let locationID = JSON["location_id"] as? String, let startDate = NSDate(JSONValue: JSON["startTime"]), let endDate = NSDate(JSONValue: JSON["endTime"]), let description = JSON["info"] as? String, let ID = JSON["id"] as? String
		else
		{
			return nil
		}
		let waitForLocation = dispatch_semaphore_create(0)
		var location: Location?
		APIManager.sharedManager.locationForID(locationID, completion: {
			location = $0
			dispatch_semaphore_signal(waitForLocation)
		})
		dispatch_semaphore_wait(waitForLocation, DISPATCH_TIME_FOREVER)
		guard let loc = location
		else
		{
			return nil
		}
		
		self.init(ID: ID, name: name, locations: [loc], startDate: startDate, endDate: endDate, description: description)
	}
	
	@objc func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(ID, forKey: "id")
		aCoder.encodeObject(name, forKey: "name")
		aCoder.encodeObject(description, forKey: "id")
		aCoder.encodeObject(JSONDateFormatter.stringFromDate(startDate), forKey: "startTime")
		aCoder.encodeObject(JSONDateFormatter.stringFromDate(endDate), forKey: "endTime")
		aCoder.encodeObject(locations.first!.ID, forKey: "location_id")
		// This ^ line makes us wonder whether its worth keeping locations as an array
	}
	
	static var jsonKeys : [String] { return ["id", "name", "info", /*"category", */"startTime", "endTime", "location_id"] }
}

func ==(lhs: Event, rhs: Event) -> Bool {
    
    return (lhs.ID == rhs.ID &&
        lhs.name == rhs.name &&
//      lhs.category == rhs.category &&
        lhs.locations == rhs.locations &&
        lhs.startDate == rhs.startDate &&
        lhs.endDate == rhs.endDate &&
        lhs.description == rhs.description)
}
