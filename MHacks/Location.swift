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
	private let floorID: String?
	var floor : Floor? {
		guard let floorID = floorID
			else { return nil }
		return APIManager.shared.floors[floorID]
	}
	
	init(ID: String, name: String, floorID: String?) {
		self.ID = ID
		self.name = name
		self.floorID = floorID
	}
	
	private static let nameKey = "name"
	private static let floorKey = "floor"
	
	convenience init?(_ serializedRepresentation: SerializedRepresentation) {
		guard let id = serializedRepresentation[Location.idKey] as? String, let locationName = serializedRepresentation[Location.nameKey] as? String
		else {
			return nil
		}
		self.init(ID: id, name: locationName, floorID: serializedRepresentation[Location.floorKey] as? String)
	}
	
	func toSerializedRepresentation() -> NSDictionary {
		var dict = [Location.idKey: ID, Location.nameKey: name]
		if let floorID = floorID
		{
			dict[Location.floorKey] = floorID
		}
		return dict as NSDictionary
	}
}


