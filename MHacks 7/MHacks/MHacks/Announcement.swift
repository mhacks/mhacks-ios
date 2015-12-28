//
//  Announcement.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import Foundation

final class Announcement: Equatable {
	
	let ID: String
	let title: String
	let message: String
	let date: NSDate

	init(ID: String, title: String, message: String, date: NSDate) {
		self.ID = ID
		self.title = title
		self.message = message
		self.date = date
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
		let formatter = NSCalendar.currentCalendar().isDateInToday(date) ? Announcement.todayDateFormatter : Announcement.otherDayDateFormatter
		return formatter.stringFromDate(date)
	}
} 

extension Announcement: JSONCreateable, NSCoding {
	
	convenience init?(JSON: [String : AnyObject]) {
		guard let id = JSON["id"] as? String, let title = JSON["name"] as? String, let message = JSON["info"] as? String, let date = NSDate(JSONValue: JSON["broadcastTime"]) where NSDate(timeIntervalSinceNow: 0) > date
		else
		{
			return nil
		}
		self.init(ID: id, title: title, message: message, date: date)
	}
	static var jsonKeys : [String] { return ["id", "name", "info", "broadcastTime"] }
	
	@objc func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(ID, forKey: "id")
		aCoder.encodeObject(title, forKey: "name")
		aCoder.encodeObject(message, forKey: "info")
		aCoder.encodeObject(JSONDateFormatter.stringFromDate(date), forKey: "broadcastTime")
	}
	@objc convenience init?(coder aDecoder: NSCoder) {
		self.init(JSON: aDecoder.dictionaryWithValuesForKeys(APIManager.Authenticator.jsonKeys))
	}
}

func ==(lhs: Announcement, rhs: Announcement) -> Bool {
	return (lhs.ID == rhs.ID &&
		lhs.title == rhs.title &&
		lhs.date == rhs.date &&
		lhs.message == rhs.message)
}
