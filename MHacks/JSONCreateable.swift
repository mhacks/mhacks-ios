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
	private let JSON : [String: AnyObject]?
	private let coder : NSCoder?
	
	init(JSON: [String: AnyObject]) {
		self.JSON = JSON
		self.coder = nil
		super.init()
	}
	init(coder: NSCoder) {
		self.coder = coder
		self.JSON = nil
		super.init()
	}
	
	subscript(key: String) -> AnyObject? {
		let value = JSON?[key] ?? coder?.decodeObjectForKey(key)
		if value == nil {
			print("Failed to decode for key: \(key)")
		}
		return value
	}
	
	func doubleValueForKey(key: String) -> Double? {
		let value = JSON?[key] as? Double ?? (coder?.decodeObjectForKey(key) as? NSNumber)?.doubleValue
		if value == nil
		{
			print("Failed to decode for key: \(key)")
		}
		return value
	}
	func intValueForKey(key: String) -> Int? {
		let value = JSON?[key] as? Int ?? (coder?.decodeObjectForKey(key) as? NSNumber)?.integerValue
		if value == nil
		{
			print("Failed to decode for key: \(key)")
		}
		return value
	}
	func boolValueForKey(key: String) -> Bool? {
		let value = JSON?[key] as? Bool ?? (coder?.decodeObjectForKey(key) as? NSNumber)?.boolValue
		if value == nil
		{
			print("Failed to decode for key: \(key)")
		}
		return value
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
	// nothing to do with how our code is organized.
}

/// A nice little wrapper to allow for interested parties to get to the JSON directly
final class JSONWrapper: JSONCreateable {
	let JSON : [String: AnyObject]
	
	@objc init?(serialized: Serialized) {
		// Just set and always succeed.
		// This is in case a request is made and we don't need to cast to any
		// particular type and just want the JSON back.
		self.JSON = serialized.JSON ?? [String: AnyObject]()
	}
	@objc func encodeWithCoder(aCoder: NSCoder) {
	}
	@objc convenience init?(coder aDecoder: NSCoder) {
		return nil
	}
	subscript(key: String) -> AnyObject? {
		return JSON[key]
	}
}

func ==(lhs: JSONWrapper, rhs: JSONWrapper) -> Bool {
	return lhs.JSON.map { $0.0 } == rhs.JSON.map { $0.0 }
}

