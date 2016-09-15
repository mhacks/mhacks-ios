//
//  Event.swift
//  MHacks
//
//  Created by Russell Ladd on 9/30/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation
import UIKit


final class Event: SerializableElementWithIdentifier {
 
	enum Category: Int, CustomStringConvertible {
		case logisitics = 0
		case social = 1
		case food = 2
		case techTalk = 3
		case other = 4
		var color: UIColor {
			switch self {
			case .logisitics:
				return UIColor(red: 056.0/255.0, green: 093.0/255.0, blue: 214.0/255.0, alpha: 1.0)
			case .social:
				return UIColor(red: 226.0/255.0, green: 048.0/255.0, blue: 082.0/255.0, alpha: 1.0)
			case .food:
				return UIColor(red: 255.0/255.0, green: 202.0/255.0, blue: 011.0/255.0, alpha: 1.0)
			case .techTalk:
				return UIColor(red: 168.0/255.0, green: 110.0/255.0, blue: 219.0/255.0, alpha: 1.0)
			case .other:
				return UIColor(red: 247.0/255.0, green: 139.0/255.0, blue: 049.0/255.0, alpha: 1.0)
			}
		}
		var description : String {
			switch self {
			case .logisitics:
				return "Logisitics"
			case .social:
				return "Social"
			case .food:
				return "Food"
			case .techTalk:
				return "Tech Talk"
			case .other:
				return "Other"
			}
		}
	}
	
	let ID: String
    let name: String
	let category: Category
	fileprivate let locationIDs: [String]
    let startDate: Date
	var endDate: Date {
		return startDate.addingTimeInterval(duration)
	}
    let duration: Double
    let information: String
	
	init(ID: String, name: String, category: Category, locationIDs: [String], startDate: Date, duration: Double, info: String) {
		self.ID = ID
		self.name = name
		self.category = category
		self.locationIDs = locationIDs
		self.startDate = startDate
		self.duration = duration
		self.information = info
	}

	
    var timeInterval: Range<TimeInterval> {
        return startDate.timeIntervalSinceReferenceDate..<endDate.timeIntervalSinceReferenceDate
    }
	
	var locations: [Location] {
		return locationIDs.flatMap { locationID in
			APIManager.shared.locations[locationID]
		}
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

extension Event {
	private static let nameKey = "name"
	private static let locationIDsKey = "locations"
	private static let startDateKey = "start"
	private static let durationKey = "duration"
	private static let infoKey = "info"
	private static let categoryKey = "category"
	
	convenience init?(_ serialized: SerializedRepresentation) {
		guard let name = serialized[Event.nameKey] as? String, let categoryRaw = serialized[Event.categoryKey] as? Int, let locationIDs = serialized[Event.locationIDsKey] as? [String], let category = Category(rawValue: categoryRaw), let startDate = serialized[Event.startDateKey] as? Double, let duration = serialized[Event.durationKey] as? Double, let description = serialized[Event.infoKey] as? String, let ID = serialized[Event.idKey] as? String
		else {
			return nil
		}
		self.init(ID: ID, name: name, category: category, locationIDs: locationIDs, startDate: Date(timeIntervalSince1970: startDate), duration: duration, info: description)
	}
	func toSerializedRepresentation() -> NSDictionary {
		return [Event.idKey: ID, Event.nameKey: name, Event.locationIDsKey: locationIDs as NSArray, Event.startDateKey: startDate.timeIntervalSince1970, Event.durationKey: duration, Event.infoKey: information, Event.categoryKey: category.rawValue]
	}
}
func < (lhs: Event, rhs: Event) -> Bool {
	return lhs.startDate < rhs.startDate
}

