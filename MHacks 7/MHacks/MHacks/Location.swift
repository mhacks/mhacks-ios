//
//  Location.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/22/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import Foundation
import CoreLocation

// This is intentionally a class, we don't duplicate copies of this everywhere, just immutable references.
final class Location {
	
	let ID: String
	let name: String
	let coreLocation: CLLocation
	init(ID: String, name: String, coreLocation: CLLocation) {
		self.ID = ID
		self.name = name
		self.coreLocation = coreLocation
	}
}
extension Location : JSONCreateable {
	convenience init?(JSON: [String: AnyObject]) {
		guard let latitude = Double(JSON["latitude"] as? String ?? ""), let longitude = Double(JSON["longitude"] as? String ?? ""), let id = JSON["id"] as? Int, let locationName = JSON["name"] as? String
			else
		{
			return nil
		}
		self.init(ID: "\(id)", name: locationName, coreLocation: CLLocation(latitude: latitude, longitude: longitude))
	}
	
	static var jsonKeys : [String] { return ["id", "name", "latitude", "longitude"] }
	
	@objc func encodeWithCoder(aCoder: NSCoder) {
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