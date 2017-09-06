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
		case general = 0, logisitics, food, learn, social
		
		var color: UIColor {
			switch self {
			case .general:
				return MHacksColor.blue
			case .logisitics:
				return MHacksColor.orange
			case .food:
				return MHacksColor.yellow
			case .learn:
				return MHacksColor.purple
			case .social:
				return MHacksColor.red
			}
		}
		var description : String {
			switch self {
			case .general:
				return "General"
			case .logisitics:
				return "Logisitics"
			case .food:
				return "Food"
			case .learn:
				return "Learn"
			case .social:
				return "Social"
			}
		}
	}
	
	let ID: String
	static var resultsKey: String {
		return "events"
	}
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

