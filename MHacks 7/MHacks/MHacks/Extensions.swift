//
//  Extensions.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/18/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import Foundation

// This file is to make Foundation more Swifty


final class MyArray<Element: JSONCreateable> : JSONCreateable {
	
	let _array : [Element]
	init?(JSON: [String: AnyObject])
	{
		guard let JSONs = JSON["results"] as? [[String: AnyObject]]
		else
		{
			_array = []
			return nil
		}
		_array = JSONs.flatMap({ Element(JSON: $0) })
	}
	init(_ elems: [Element] = []) { _array = elems }
	static var jsonKeys : [String] { return [] }
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
