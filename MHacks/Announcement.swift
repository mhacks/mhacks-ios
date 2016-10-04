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
			switch self.rawValue {
			case Category.emergency.rawValue:
				return MHacksColor.red
			case Category.logistics.rawValue:
				return MHacksColor.orange
			case Category.food.rawValue:
				return MHacksColor.yellow
			case Category.events.rawValue:
				return MHacksColor.blue
			default:
				return MHacksColor.plain
			}
		}
	}
	
	var ID: String
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
	private static let infoKey = "info"
	private static let titleKey = "title"
	private static let dateKey = "broadcast_at"
	private static let categoryKey = "category"
	private static let approvedKey = "approved"

	init?(_ serializedRepresentation: SerializedRepresentation) {
		guard let id = serializedRepresentation[Announcement.idKey] as? String, let title = serializedRepresentation[Announcement.titleKey] as? String, let message = serializedRepresentation[Announcement.infoKey] as? String, let date = serializedRepresentation[Announcement.dateKey] as? Double, let categoryRaw = serializedRepresentation[Announcement.categoryKey] as? Int, let approved = serializedRepresentation[Announcement.approvedKey] as? Bool
			else {
				return nil
		}
		self.init(ID: id, title: title, message: message, date: Date(timeIntervalSince1970: date), category: Category(rawValue: categoryRaw), approved: approved)
	}
	func toSerializedRepresentation() -> NSDictionary {
		return [Announcement.idKey: ID, Announcement.titleKey: title, Announcement.dateKey: date.timeIntervalSince1970, Announcement.infoKey: message, Announcement.categoryKey: category.rawValue, Announcement.approvedKey: approved]
	}
}


func <(lhs: Announcement, rhs: Announcement) -> Bool {
	return lhs.date > rhs.date
}

