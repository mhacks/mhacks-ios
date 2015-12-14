//
//  JSONCreateable.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MPowered. All rights reserved.
//

import Foundation


protocol JSONCreateable
{
	init?(JSON: [String: Any])
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
		guard let JSON = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String: Any]
		else
		{
			return nil
		}
		self.init(JSON: JSON)
	}
}

extension Array where Element: JSONCreateable
{
	init?(JSONData data: NSData?)
	{
		guard let data = data
			else
		{
			return nil
		}
		guard let JSONs = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [[String: Any]]
			else
		{
			return nil
		}
		self = JSONs.flatMap { Element(JSON: $0) }
	}
}