//
//  JSONCreateable.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import Foundation

protocol JSONCreateable
{
	init?(JSON: [String: AnyObject])
	static var jsonKeys : [String] { get }
	func encodeWithCoder(aCoder: NSCoder)
	init?(coder aDecoder: NSCoder)
}

extension JSONCreateable
{
	init?(data: NSData?)
	{
		guard let data = data
		else
		{
			return nil
		}
		guard let JSON = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String: AnyObject]
		else
		{
			return nil
		}
		self.init(JSON: JSON)
	}
	init?(coder aDecoder: NSCoder)
	{
		self.init(JSON: aDecoder.dictionaryWithValuesForKeys(Self.jsonKeys))
	}
}


/// A nice little wrapper to allow for interested parties to get to the JSON directly
struct JSONWrapper: JSONCreateable
{
	let JSON : [String: AnyObject]
	static let jsonKeys: [String] = [String]()
	
	func encodeWithCoder(aCoder: NSCoder) {
	}
	
	init?(JSON: [String: AnyObject])
	{
		// Just set and always succeed.
		// This is in case a request is made and we don't need to cast to any 
		// particular type and just want the JSON back.
		self.JSON = JSON
	}
}
