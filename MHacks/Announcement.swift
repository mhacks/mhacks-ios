//
//  Announcement.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import UIKit

struct Announcement: SerializableElementWithIdentifier {
	
	struct Category : OptionSet, CustomStringConvertible {
		
		let rawValue : Int
		
		static let none = Category(rawValue: 0 << 0)
		static let emergency = Category(rawValue: 1 << 0)
		static let logistics = Category(rawValue: 1 << 1)
		static let food = Category(rawValue: 1 << 2)
		static let events = Category(rawValue: 1 << 3)
		static let sponsor = Category(rawValue: 1 << 4)
		
		static let all: [Category] = [.events, .food, .logistics, .emergency, .sponsor]
		
		var description: String {
			switch self.rawValue
			{
			case Category.emergency.rawValue:
				return "emergency"
			case Category.logistics.rawValue:
				return "logistics"
			case Category.food.rawValue:
				return "food"
			case Category.events.rawValue:
				return "event"
			case Category.sponsor.rawValue:
				return "sponsored"
			default:
				return "None"
			}
		}

		var descriptionDisplay: String {
			switch self.rawValue
			{
			case Category.emergency.rawValue:
				return "Emergency"
			case Category.logistics.rawValue:
				return "Logistics"
			case Category.food.rawValue:
				return "Food"
			case Category.events.rawValue:
				return "Events"
			case Category.sponsor.rawValue:
				return "Sponsor"
			default:
				return "None"
			}
		}
		
		var color: UIColor {
			
			if contains(.emergency) {
				return MHacksColor.red
			} else if contains(.logistics) {
				return MHacksColor.orange
			} else if contains(.food) {
				return MHacksColor.yellow
			} else if contains(.events) {
				return MHacksColor.blue
			} else {
				return MHacksColor.plain
			}
		}
	}
	
	var ID: String
	static let resultsKey: String = "announcements"
	var title: String
	var message: String
	var date: Date
	var category: Category
	var approved: Bool
	var isSponsored: Bool {
		return self.category.contains(Announcement.Category.sponsor)
	}
		
	static private let todayDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.timeStyle = .short
		return formatter;
	}()
	
	static private let otherDayDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.doesRelativeDateFormatting = true;
		return formatter;
	}()
	
	static func localizedDate(for date: Date) -> String {
		let formatter = Calendar.current.isDateInToday(date) ? Announcement.todayDateFormatter : Announcement.otherDayDateFormatter
		return formatter.string(from: date)
	}
	
	var localizedDate: String {
		return Announcement.localizedDate(for: date)
	}
}

extension Announcement
{
	private static let infoKey = "body"
	private static let titleKey = "title"
	private static let dateKey = "broadcastTime_ts"
	private static let categoryKey = "category"
	private static let approvedKey = "isApproved"

	init?(_ serializedRepresentation: SerializedRepresentation) {
		guard
			let id = serializedRepresentation[Announcement.idKey] as? String,
			let title = serializedRepresentation[Announcement.titleKey] as? String,
			let message = serializedRepresentation[Announcement.infoKey] as? String,
			let date = serializedRepresentation[Announcement.dateKey] as? Double,
			let categoryString = serializedRepresentation[Announcement.categoryKey] as? String,
			let approved = serializedRepresentation[Announcement.approvedKey] as? Bool
			else {
				return nil
		}
		self.init(
			ID: id,
			title: title,
			message: message,
			date: Date(timeIntervalSince1970: date / 1000),
			category: Category(rawValue: Announcement.getCategoryValue(type: categoryString)),
			approved: approved
		)
	}
	
	func toSerializedRepresentation() -> NSDictionary {
		return [
			Announcement.idKey: ID,
			Announcement.titleKey: title,
			Announcement.dateKey: date.timeIntervalSince1970 * 1000,
			Announcement.infoKey: message,
			Announcement.categoryKey: category.description,
			Announcement.approvedKey: approved
		]
	}
	
	static func getPreferenceList(preferenceValue: Int) -> String {
		var preferences = [String]()
		var bit = 1
		
		while (bit < 64) {
			if preferenceValue & bit == bit {
				let category = Category(rawValue: bit)
				if category.description != "None" {
					preferences.append(category.description)
				}
			}
			bit <<= 1
		}
		
		return preferences.joined(separator: ",")
	}
	
	static func getPreferenceValue(preferences: [String]) -> Int {
		return preferences.reduce(0, {$0 + Announcement.getCategoryValue(type: $1)})
	}
	
	static func getCategoryValue(type: String) -> Int {
		switch type {
		case "emergency":
			return 1
		case "logistics":
			return 2
		case "food":
			return 4
		case "event":
			return 8
		case "sponsored":
			return 16
		default:
			return 0
		}
	}
}


func <(lhs: Announcement, rhs: Announcement) -> Bool {
	return lhs.date > rhs.date
}

