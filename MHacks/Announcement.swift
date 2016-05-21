//
//  Announcement.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import UIKit

@objc final class Announcement: NSObject {
	
	struct Category : OptionSetType, CustomStringConvertible {
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
			return categories.joinWithSeparator(", ")
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
					return UIColor(red: 255.0/255.0, green: 050.0/255.0, blue: 050.0/255.0, alpha: 1.0)
				case 1:
					return UIColor(red: 030.0/255.0, green: 103.0/255.0, blue: 254.0/255.0, alpha: 1.0)
				case 2:
					return UIColor(red: 255.0/255.0, green: 200.0/255.0, blue: 008.0/255.0, alpha: 1.0)
				case 3:
					return  UIColor(red: 057.0/255.0, green: 203.0/255.0, blue: 085.0/255.0, alpha: 1.0)
				case 4:
					return UIColor(red: 158.0/255.0, green: 030.0/255.0, blue: 229.0/255.0, alpha: 1.0)
				case 5:
					return UIColor(red: 247.0/255.0, green: 139.0/255.0, blue: 049.0/255.0, alpha: 1.0)
				default:
					fatalError("Unrecognized category \(i)")
				}
			}
			return UIColor.blueColor()
		}
	}
	
	let ID: String
	let title: String
	let message: String
	let date: NSDate
	let category: Category
	let owner: String
	let approved: Bool
	
	init(ID: String, title: String, message: String, date: NSDate, category: Category, owner: String, approved: Bool) {
		self.ID = ID
		self.title = title
		self.message = message
		self.date = date
		self.category = category
		self.owner = owner
		self.approved = approved
	}
	
	static private let todayDateFormatter: NSDateFormatter = {
		let formatter = NSDateFormatter()
		formatter.timeStyle = .ShortStyle
		return formatter;
	}()
	
	static private let otherDayDateFormatter: NSDateFormatter = {
		let formatter = NSDateFormatter()
		formatter.dateStyle = .ShortStyle
		formatter.doesRelativeDateFormatting = true;
		return formatter;
	}()
	
	var localizedDate: String {
		let formatter = NSCalendar.sharedCalendar.isDateInToday(date) ? Announcement.todayDateFormatter : Announcement.otherDayDateFormatter
		return formatter.stringFromDate(date)
	}
	private static let idKey = "id"
	private static let infoKey = "info"
	private static let titleKey = "name"
	private static let dateKey = "broadcast_time"
	private static let categoryKey = "category"
	private static let ownerKey = "user_id"
	private static let approvedKey = "is_approved"
	
	static let dateFont: UIFont = {
		// Use SF font with monospaced digit for iOS 9+
		return UIFont.systemFontOfSize(14.0, weight: UIFontWeightThin)
	}()

	@objc convenience init?(serialized: Serialized) {
		guard let id = serialized[Announcement.idKey] as? String, let title = serialized[Announcement.titleKey] as? String, let message = serialized[Announcement.infoKey] as? String, let date = NSDate(JSONValue: serialized[Announcement.dateKey]), let categoryRaw = serialized.intValueForKey(Announcement.categoryKey), let owner = serialized[Announcement.ownerKey] as? String, let approved = serialized.boolValueForKey(Announcement.approvedKey)
		else
		{
			return nil
		}
		self.init(ID: id, title: title, message: message, date: date, category: Category(rawValue: categoryRaw), owner: owner, approved: approved)
	}
	func encodeForCreation() -> [String: AnyObject]
	{
		return [Announcement.titleKey: title, Announcement.dateKey: JSONDateFormatter.stringFromDate(date), Announcement.infoKey: message, Announcement.categoryKey: category.rawValue]
	}
} 

extension Announcement: JSONCreateable, NSCoding {
		
	@objc func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encode(ID, forKey: Announcement.idKey)
		aCoder.encode(title, forKey: Announcement.titleKey)
		aCoder.encode(message, forKey: Announcement.infoKey)
		aCoder.encode(JSONDateFormatter.stringFromDate(date), forKey: Announcement.dateKey)
		aCoder.encode(approved, forKey: Announcement.approvedKey)
		aCoder.encode(owner, forKey: Announcement.ownerKey)
		aCoder.encode(category.rawValue, forKey: Announcement.categoryKey)
	}
	@objc convenience init?(coder aDecoder: NSCoder) {
		self.init(serialized: Serialized(coder: aDecoder))
	}
}

func ==(lhs: Announcement, rhs: Announcement) -> Bool {
	return (lhs.ID == rhs.ID &&
		lhs.title == rhs.title &&
		lhs.date == rhs.date &&
		lhs.message == rhs.message)
}
