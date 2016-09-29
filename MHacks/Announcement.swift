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
		static let None = Category(rawValue: 0 << 0)
		static let Emergency = Category(rawValue: 1 << 0)
		static let Logistics = Category(rawValue: 1 << 1)
		static let Food = Category(rawValue: 1 << 2)
		static let Swag = Category(rawValue: 1 << 3)
		static let Sponsor = Category(rawValue: 1 << 4)
		static let Other = Category(rawValue: 1 << 5)
		
		static let maxBit = 5
		var description: String {
			var categories = [String]()
			for i in 0...Category.maxBit
			{
				guard self.contains(Category(rawValue: 1 << i))
				else {
					continue
				}
				categories.append( {
					switch i
					{
					case 0:
						return "Emergency"
					case 1:
						return "Logistics"
					case 2:
						return "Food"
					case 3:
						return "Swag"
					case 4:
						return "Sponsor"
					case 5:
						return "Other"
					default:
						fatalError("Unrecognized category \(i)")
					}
				}())
			}
			guard categories.count > 0
			else {
				return "None"
			}
			return categories.joined(separator: ", ")
		}
		var color: UIColor {
			for i in 0...Category.maxBit
			{
				guard self.contains(Category(rawValue: 1 << i))
				else {
					continue
				}
				switch i
				{
				case 0:
					return ColorPalette.Category.Emergency
				case 1:
					return ColorPalette.Category.Logistics
				case 2:
					return ColorPalette.Category.Food
				case 3:
					return ColorPalette.Category.Swag
				case 4:
					return ColorPalette.Category.Sponsor
				case 5:
					return ColorPalette.Category.Other
				default:
					fatalError("Unrecognized category \(i)")
				}
			}
			return UIColor.blue
		}
	}
	
	var ID: String
	var title: String
	var message: String
	var date: Date
	var category: Category
	var approved: Bool
	var isSponsored: Bool {
		return self.category.contains(Announcement.Category.Sponsor)
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
	
	var localizedDate: String {
		let formatter = Calendar.shared.isDateInToday(date) ? Announcement.todayDateFormatter : Announcement.otherDayDateFormatter
		return formatter.string(from: date)
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
	return lhs.date < rhs.date
}

