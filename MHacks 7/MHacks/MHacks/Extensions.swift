//
//  Extensions.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/18/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import Foundation

// This file is to make Foundation more Swifty

extension Array : JSONCreateable
{
	
	init?(JSON: [String: AnyObject])
	{
		// TODO: Ask backend people to wrap arrays inside the dictionary with a results key
		guard Element.self is JSONCreateable
			else
		{
			// If Element is not JSONCreateable, what are we doing here?
			// Ideally, we would restrict the extension using where Element == JSONCreateable
			// But in Swift 2.0 that's not possible.
			return nil
		}
		guard let JSONs = JSON["results"] as? [[String: AnyObject]]
			else
		{
			return nil
		}
		// This is one ugly line of code, but what can we do it enables us to do some remarkable things.
		self = JSONs.flatMap({ (Element.self as! JSONCreateable).dynamicType.init(JSON: $0) as? Element })
	}
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

extension NSDate
{
	convenience init?(JSONValue: AnyObject)
	{
		guard let dateString = JSONValue as? String
		else
		{
			return nil
		}
		let dateFormatter = NSDateFormatter()
		
	}
}
