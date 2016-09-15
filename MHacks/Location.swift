//
//  Location.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/22/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import Foundation
import CoreLocation

// We have a class here since we don't want to pay the performance overhead of copies however, the correct thing to do
// would be to implement this as a struct with copy-on-write semantics but its a bit tedious and we don't 
// "really" need it so we just stick with immutable references.
final class Location : SerializableElementWithIdentifier {
	
	let ID: String
	let name: String
	let coreLocation: CLLocation
	
	init(ID: String, name: String, coreLocation: CLLocation) {
		self.ID = ID
		self.name = name
		self.coreLocation = coreLocation
	}
	
	private static let nameKey = "name"
	private static let latitudeKey = "latitude"
	private static let longitudeKey = "longitude"
	
	convenience init?(_ serializedRepresentation: SerializedRepresentation) {
		guard let id = serializedRepresentation[Location.idKey] as? String, let locationName = serializedRepresentation[Location.nameKey] as? String, let latitude = serializedRepresentation[Location.latitudeKey] as? Double, let longitude = serializedRepresentation[Location.longitudeKey] as? Double
		else {
			return nil
		}
		self.init(ID: id, name: locationName, coreLocation: CLLocation(latitude: latitude, longitude: longitude))

	}
	
	func toSerializedRepresentation() -> NSDictionary {
		return [Location.idKey: ID, Location.nameKey: name, Location.latitudeKey: coreLocation.coordinate.latitude, Location.longitudeKey: coreLocation.coordinate.longitude]
	}
}


