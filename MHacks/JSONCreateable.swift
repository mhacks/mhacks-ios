//
//  JSONCreateable.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import Foundation

/// A single interface wrapper around JSON and a coder
/// Provides convenient abstractions like []. If you are using it to query
/// a number type or a boolean use the `numberType`ForKey. If the type you
/// want doesn't have it feel free to define it. This isn't a preferred way of
/// doing things but we have no choice since bridiging doesn't work properly.
@objc final class Serialized : NSObject {
	let _JSON : [String: AnyObject]?
	let _coder : NSCoder?
	
	init(JSON: [String: AnyObject]) {
		self._JSON = JSON
		self._coder = nil
		super.init()
	}
	init(coder: NSCoder) {
		self._coder = coder
		self._JSON = nil
		super.init()
	}
	
	subscript(key: String) -> AnyObject? {
		return _JSON?[key] ?? _coder?.decodeObjectForKey(key)
	}
	
	func doubleValueForKey(key: String) -> Double? {
		return _JSON?[key] as? Double ?? (_coder?.decodeObjectForKey(key) as? NSNumber)?.doubleValue
	}
	func intValueForKey(key: String) -> Int? {
		return _JSON?[key] as? Int ?? (_coder?.decodeObjectForKey(key) as? NSNumber)?.integerValue
	}
	func boolValueForKey(key: String) -> Bool? {
		return _JSON?[key] as? Bool ?? (_coder?.decodeObjectForKey(key) as? NSNumber)?.boolValue
	}
}

protocol JSONCreateable : NSCoding
{
	init?(serialized: Serialized)
}

extension JSONCreateable
{
	init?(JSON: [String: AnyObject]) {
		self.init(serialized: Serialized(JSON: JSON))
	}
	init?(data: NSData?) {
		guard let data = data
		else
		{
			return nil
		}
		guard let JSON = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String: AnyObject]
		else
		{
			guard let JSONs = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [[String: AnyObject]]
			else {
				return nil
			}
			self.init(JSON: ["results": JSONs])
			return
		}
		self.init(JSON: JSON)
	}
	
	// It kinda sucks that we cannot have init?(coder: NSCoder) in here but unfortunately we cannot mark it as @objc and
	// so we are left to deal with it by simply having:
	//
	//		@objc convenience init?(coder aDecoder: NSCoder) {
	//			self.init?(serialzed: Serialzed(coder: aDecoder))
	//		}
	//
	// in all classes that conform to JSONCreateable!
	//
	// However, this is purely because of a limitation on Swift's typesystem and Objective-C interoperatbility and has
	// nothing to do with the how our code is organized.
}

