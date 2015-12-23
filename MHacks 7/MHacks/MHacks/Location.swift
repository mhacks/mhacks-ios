//
//  Location.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/22/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import Foundation
import CoreLocation

// This is intentionally a class, we dont duplicate copies of this everywhere, just immutable references.
final class Location : JSONCreateable {
	
	let ID: String
	let name: String
	let coreLocation: CLLocation
	
	required init?(JSON: [String: AnyObject]) {
		guard let latitude = JSON["latitude"] as? Double, let longitude = JSON["longitude"] as? Double, let id = JSON["id"] as? String, let locationName = JSON["name"] as? String
		else
		{
			ID = ""
			name = ""
			coreLocation = CLLocation()
			return nil
		}
		ID = id
		coreLocation = CLLocation(latitude: latitude, longitude: longitude)
		name = locationName
	}
	
	static var jsonKeys : [String] { return ["id", "name", "latitude", "longitude"] }
	
	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(ID, forKey: "id")
		aCoder.encodeDouble(coreLocation.coordinate.latitude, forKey: "latitude")
		aCoder.encodeDouble(coreLocation.coordinate.longitude, forKey: "longitude")
		aCoder.encodeObject(name, forKey: "name")
	}
}
extension Location : Equatable { }

func ==(lhs: Location, rhs: Location) -> Bool
{
	return lhs.ID == rhs.ID && lhs.coreLocation == rhs.coreLocation && lhs.name == rhs.name
}