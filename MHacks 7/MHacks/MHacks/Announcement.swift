//
//  Announcement.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import Foundation

@objc final class Announcement: NSObject {
	
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
		let formatter = NSCalendar.sharedCalendar.isDateInToday(date) ? Announcement.todayDateFormatter : Announcement.otherDayDateFormatter
		return formatter.stringFromDate(date)
	}
	private static let idKey = "id"
	private static let infoKey = "info"
	private static let nameKey = "name"
	private static let dateKey = "broadcastTime"
	
	@objc convenience init?(serialized: Serialized) {
		guard let id : Any = serialized[Announcement.idKey] as? Int ?? serialized[Announcement.idKey] as? String, let title = serialized[Announcement.nameKey] as? String, let message = serialized[Announcement.infoKey] as? String, let date = NSDate(JSONValue: serialized[Announcement.dateKey]) where NSDate(timeIntervalSinceNow: 0) > date
		else
		{
			return nil
		}
		self.init(ID: "\(id)", title: title, message: message, date: date)
	}
} 

extension Announcement: JSONCreateable, NSCoding {
		
	@objc func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(ID, forKey: Announcement.idKey)
		aCoder.encodeObject(title, forKey: Announcement.nameKey)
		aCoder.encodeObject(message, forKey: Announcement.infoKey)
		aCoder.encodeObject(JSONDateFormatter.stringFromDate(date), forKey: Announcement.dateKey)
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
