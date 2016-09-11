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
    let locations: [Location]
    let startDate: Date
    let endDate: Date
    let information: String
	
	init(ID: String, name: String, category: Category, locations: [Location], startDate: Date, endDate: Date, info: String) {
		self.ID = ID
		self.name = name
		self.category = category
		self.locations = locations
		self.startDate = startDate
		self.endDate = endDate
		self.information = info
	}

	
    var timeInterval: Range<TimeInterval> {
        return startDate.timeIntervalSinceReferenceDate..<endDate.timeIntervalSinceReferenceDate
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
	
	convenience init?(ID: String, name: String, category: Category, locationIDs: [String], startDate: Date, endDate: Date, info: String) {
		let locations = locationIDs.flatMap { locationID in
			APIManager.shared.locations.filter { $0.ID == locationID
			}
		}
		guard locations.count > 0 else { return nil }
		self.init(ID: ID, name: name, category: category, locations: locations, startDate: startDate, endDate: endDate, info: info)
	}

}

extension Event {
	private static let idKey = "id"
	private static let nameKey = "name"
	private static let locationIDsKey = "location_ids"
	private static let startDateKey = "start_time"
	private static let endDateKey = "end_time"
	private static let infoKey = "info"
	private static let categoryKey = "category"
	
	convenience init?(_ serialized: SerializedRepresentation) {
		guard let name = serialized[Event.nameKey] as? String, let categoryRaw = serialized[Event.categoryKey] as? Int, let category = Category(rawValue: categoryRaw), let locationIDs = serialized[Event.locationIDsKey] as? [String], let startDate = serialized[Event.startDateKey] as? Double, let endDate = serialized[Event.endDateKey] as? Double, let description = serialized[Event.infoKey] as? String, let ID = serialized[Event.idKey] as? String, startDate <= endDate
		else {
			return nil
		}
		self.init(ID: ID, name: name, category: category, locationIDs: locationIDs, startDate: Date(timeIntervalSince1970: startDate), endDate: Date(timeIntervalSince1970: endDate), info: description)
	}
	func toSerializedRepresentation() -> NSDictionary {
		return [Event.idKey: ID, Event.nameKey: name, Event.locationIDsKey: locations.map { $0.ID } as NSArray, Event.startDateKey: startDate.timeIntervalSince1970, Event.endDateKey: endDate.timeIntervalSince1970, Event.infoKey: information, Event.categoryKey: category.rawValue]
	}
}
func < (lhs: Event, rhs: Event) -> Bool {
	return lhs.startDate < rhs.startDate
}

