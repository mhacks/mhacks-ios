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
 
	enum Category: Int, CustomStringConvertible {
		case Logisitics = 0
		case Social = 1
		case Food = 2
		case TechTalk = 3
		case Other = 4
		var color: UIColor {
			switch self {
			case .Logisitics:
				return UIColor.blueColor()
			case .Social:
				return UIColor.redColor()
			case .Food:
				return UIColor.yellowColor()
			case .TechTalk:
				return UIColor.purpleColor()
			case .Other:
				return UIColor.brownColor()
			}
		}
		var description : String {
			switch self {
			case .Logisitics:
				return "Logisitics"
			case .Social:
				return "Social"
			case .Food:
				return "Food"
			case .TechTalk:
				return "Tech Talk"
			case .Other:
				return "Other"
			}
		}
	}
	
    let ID: String
    let name: String
	let category: Category
    var locations: [Location]
    let startDate: NSDate
    let endDate: NSDate
    let information: String
	
	init(ID: String, name: String, category: Category, locations: [Location], startDate: NSDate, endDate: NSDate, info: String) {
		self.ID = ID
		self.name = name
		self.category = category
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
	private static let locationIDsKey = "location_ids"
	private static let startDateKey = "start_time"
	private static let endDateKey = "end_time"
	private static let infoKey = "info"
	private static let idKey = "id"
	private static let categoryKey = "category"
	
	@objc convenience init?(serialized: Serialized) {
		guard let name = serialized[Event.nameKey] as? String, let categoryRaw = serialized.intValueForKey(Event.categoryKey), let category = Category(rawValue: categoryRaw), let locationIDs = serialized[Event.locationIDsKey] as?  [String], let startDate = NSDate(JSONValue: serialized[Event.startDateKey]), let endDate = NSDate(JSONValue: serialized[Event.endDateKey]), let description = serialized[Event.infoKey] as? String, let ID = serialized[Event.idKey] as? String where startDate <= endDate
		else
		{
			return nil
		}
		if let isApproved = serialized["is_approved"] as? Bool
		{
			guard isApproved
			else
			{
				return nil
			}
		}
		let locations = locationIDs.flatMap { locationForID(Int($0)) }
		guard locations.count > 0
		else
		{
			return nil
		}
		self.init(ID: ID, name: name, category: category, locations: locations, startDate: startDate, endDate: endDate, info: description)
	}

}

extension Event : JSONCreateable {
	
	@objc func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(ID, forKey: Event.idKey)
		aCoder.encodeObject(name, forKey: Event.nameKey)
		aCoder.encodeObject(information, forKey: Event.infoKey)
		aCoder.encodeObject(JSONDateFormatter.stringFromDate(startDate), forKey: Event.startDateKey)
		aCoder.encodeObject(JSONDateFormatter.stringFromDate(endDate), forKey: Event.endDateKey)
		aCoder.encodeObject(locations.map { $0.ID }, forKey: Event.locationIDsKey)
	}
	
	@objc convenience init?(coder aDecoder: NSCoder) {
		self.init(serialized: Serialized(coder: aDecoder))
	}
}

func ==(lhs: Event, rhs: Event) -> Bool {
    
    return (lhs.ID == rhs.ID &&
        lhs.name == rhs.name &&
		lhs.category == rhs.category &&
        lhs.locations == rhs.locations &&
        lhs.startDate == rhs.startDate &&
        lhs.endDate == rhs.endDate &&
        lhs.information == rhs.information)
}
