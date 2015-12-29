//
//  Extensions.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/18/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import Foundation

// This file is to make Foundation more Swifty

final class MyArray<Element: JSONCreateable> : NSObject, JSONCreateable {
	
	let _array : [Element]
	@objc init?(serialized: Serialized)
	{
		guard let JSONs = serialized["results"] as? [[String: AnyObject]]
		else
		{
			_array = []
			super.init()
			return nil
		}
		_array = JSONs.flatMap({ Element(JSON: $0) })
		super.init()
	}
	init(_ elems: [Element] = []) {
		_array = elems
		super.init()
	}
	func encodeWithCoder(aCoder: NSCoder) {
	}
	@objc convenience init?(coder aDecoder: NSCoder) {
		return nil
	}
}

/// A nice little wrapper to allow for interested parties to get to the JSON directly
final class JSONWrapper: JSONCreateable
{
	let JSON : [String: AnyObject]
	
	@objc init?(serialized: Serialized) {
		// Just set and always succeed.
		// This is in case a request is made and we don't need to cast to any
		// particular type and just want the JSON back.
		self.JSON = serialized._JSON ?? [String: AnyObject]()
	}
	@objc func encodeWithCoder(aCoder: NSCoder) {
	}
	@objc convenience init?(coder aDecoder: NSCoder) {
		return nil
	}
}
func ==(lhs: JSONWrapper, rhs: JSONWrapper) -> Bool {
	return lhs.JSON.map { $0.0 } == rhs.JSON.map { $0.0 }
}


extension NSDate: Comparable {}
public func <(lhs: NSDate, rhs: NSDate) -> Bool
{
	return lhs.compare(rhs) == .OrderedAscending
}
public func ==(lhs: NSDate, rhs: NSDate) -> Bool
{
	return lhs.compare(rhs) == .OrderedSame
}
public func >(lhs: NSDate, rhs: NSDate) -> Bool
{
	return lhs.compare(rhs) == .OrderedDescending
}
public func >=(lhs: NSDate, rhs: NSDate) -> Bool
{
	let res = lhs.compare(rhs)
	return  res == .OrderedDescending || res == .OrderedSame
}
public func <=(lhs: NSDate, rhs: NSDate) -> Bool
{
	let res = lhs.compare(rhs)
	return res == .OrderedAscending || res == .OrderedSame
}

let JSONDateFormatter : NSDateFormatter = {
	let dateFormat = NSDateFormatter()
	dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
	return dateFormat
}()

extension NSDate
{
	convenience init?(JSONValue: AnyObject?)
	{
		guard let dateString = JSONValue as? String
		else
		{
			return nil
		}
		guard let date = JSONDateFormatter.dateFromString(dateString)
		else
		{
			return nil
		}
		self.init(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate)
	}
}

extension String {
	public var sentenceCapitalizedString : String
	{
		var formatted = ""
		let range = Range(start: startIndex, end: endIndex)
		enumerateSubstringsInRange(range, options: NSStringEnumerationOptions.BySentences, { sentence, sentenceRange, enclosingRange, stop in
			guard let sentence = sentence
				else
			{
				return
			}
			formatted += sentence.stringByReplacingCharactersInRange(Range(start: self.startIndex, end: self.startIndex.advancedBy(1)), withString: sentence.substringToIndex(sentence.startIndex.successor()).capitalizedString)
		})
		// Add trailing full stop.
		if (formatted[formatted.endIndex.predecessor()] != ".")
		{
			formatted += "."
		}
		return formatted
	}
}

// MARK: - Keys

let remoteNotificationDataKey = "remote_notifications"
