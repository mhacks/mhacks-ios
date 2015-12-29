//
//  Event.swift
//  MHacks
//
//  Created by Russell Ladd on 9/30/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation
import UIKit


@objc final class Event: NSObject {
 
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
    let information: String
	
	init(ID: String, name: String, locations: [Location], startDate: NSDate, endDate: NSDate, info: String) {
		self.ID = ID
		self.name = name
		self.locations = locations
		self.startDate = startDate
		self.endDate = endDate
		self.information = info
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
	
	private static let nameKey = "name"
	private static let locationIDKey = "location_id"
	private static let startDateKey = "startTime"
	private static let endDateKey = "endTime"
	private static let infoKey = "info"
	private static let idKey = "id"
	
	
	@objc convenience init?(serialized: Serialized) {
		guard let name = serialized[Event.nameKey] as? String/*, let categoryRaw = JSON["category"] as? String, let category = Category(rawValue: categoryRaw)*/, let locationID : Any = serialized[Event.locationIDKey] as? Int ?? serialized[Event.locationIDKey] as? String, let startDate = NSDate(JSONValue: serialized[Event.startDateKey]), let endDate = NSDate(JSONValue: serialized[Event.endDateKey]), let description = serialized[Event.infoKey] as? String, let ID : Any = serialized[Event.idKey] as? Int ?? serialized[Event.idKey] as? String, let location = locationForID("\(locationID)")
		else
		{
			return nil
		}
		self.init(ID: "\(ID)", name: name, locations: [location], startDate: startDate, endDate: endDate, info: description)
	}

}

extension Event : JSONCreateable {
	
	@objc func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(ID, forKey: Event.idKey)
		aCoder.encodeObject(name, forKey: Event.nameKey)
		aCoder.encodeObject(information, forKey: Event.infoKey)
		aCoder.encodeObject(JSONDateFormatter.stringFromDate(startDate), forKey: Event.startDateKey)
		aCoder.encodeObject(JSONDateFormatter.stringFromDate(endDate), forKey: Event.endDateKey)
		aCoder.encodeObject(locations.first!.ID, forKey: Event.locationIDKey)
		// This ^ line makes us wonder whether its worth keeping locations as an array
	}
	@objc convenience init?(coder aDecoder: NSCoder) {
		self.init(serialized: Serialized(coder: aDecoder))
	}
}

func ==(lhs: Event, rhs: Event) -> Bool {
    
    return (lhs.ID == rhs.ID &&
        lhs.name == rhs.name &&
//      lhs.category == rhs.category &&
        lhs.locations == rhs.locations &&
        lhs.startDate == rhs.startDate &&
        lhs.endDate == rhs.endDate &&
        lhs.information == rhs.information)
}
