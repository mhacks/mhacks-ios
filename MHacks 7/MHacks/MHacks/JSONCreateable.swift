//
//  JSONCreateable.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import Foundation

// A single interface wrapper around JSON and a coder
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
}

