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
	static let resultsKey: String = "locations"
	let name: String
	let coordinate: CLLocationCoordinate2D?
	
	init(ID: String, name: String, coordinate: CLLocationCoordinate2D?) {
		self.ID = ID
		self.name = name
		self.coordinate = coordinate
	}
	
	private static let nameKey = "name"
	private static let latitudeKey = "latitude"
	private static let longitudeKey = "longitude"
	
	convenience init?(_ serializedRepresentation: SerializedRepresentation) {
		guard let id = serializedRepresentation[Location.idKey] as? String, let locationName = serializedRepresentation[Location.nameKey] as? String
		else {
			return nil
		}
		
		// Backend passes latitude and longitude back as strings (as of September 2017)
		// so to use same serialization/deserialization method from cache as JSON response
		// we cast to string before serialization and thus must change back to Double on deserialization
		
		var coordinate: CLLocationCoordinate2D?
		if let latitudeString = serializedRepresentation[Location.latitudeKey] as? String,
			let longitudeString = serializedRepresentation[Location.longitudeKey] as? String,
			let latitude = Double(latitudeString),
			let longitude = Double(longitudeString) {
			coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		}
		
		self.init(ID: id, name: locationName, coordinate: coordinate)
	}
	
	func toSerializedRepresentation() -> NSDictionary {
		var dict = [Location.idKey: ID, Location.nameKey: name]
		
		if let coordinate = self.coordinate {
			dict[Location.latitudeKey] = "\(coordinate.latitude)"
			dict[Location.longitudeKey] = "\(coordinate.longitude)"
		}
		
		return dict as NSDictionary
	}
}


