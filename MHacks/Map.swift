//
//  Map.swift
//  MHacks
//
//  Created by Manav Gabhawala on 2/5/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit
import CoreLocation

final class Map: Serializable {
	
	var fileLocation: String
	var imageURL: String

	private var southWestLatitude: CLLocationDegrees
	private var southWestLongitude: CLLocationDegrees
	
	private var northEastLatitude: CLLocationDegrees
	private var northEastLongitude: CLLocationDegrees
	
	let semaphoreGuard = DispatchSemaphore(value: 1)
	let coalescer = CoalescedCallbacks()
	private(set) var lastUpdated: Int?

	
	var image: UIImage
	
	var northEastCoordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: northEastLatitude, longitude: northEastLongitude)
	}
	
	var southWestCoordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: southWestLatitude, longitude: southWestLongitude)
	}
	init()
	{
		southWestLatitude = 0.0
		southWestLongitude = 0.0
		northEastLatitude = 0.0
		northEastLongitude = 0.0
		fileLocation = ""
		imageURL = ""
		image = UIImage()
	}
	
	init?(fileLocation: String, imageURL: String, southWestLatitude : CLLocationDegrees, southWestLongitude : CLLocationDegrees, northEastLatitude: CLLocationDegrees, northEastLongitude: CLLocationDegrees, lastUpdated: Int?)
	{
		guard let URL = URL(string: fileLocation), let data = try? Data(contentsOf: URL), let image = UIImage(data: data)
		else {
			return nil
		}
		
		self.fileLocation = fileLocation
		self.imageURL = imageURL
		self.southWestLatitude = southWestLatitude
		self.southWestLongitude = southWestLongitude
		self.northEastLatitude = northEastLatitude
		self.northEastLongitude = northEastLongitude
		self.image = image
		self.lastUpdated = lastUpdated
	}
}
extension Map {
	
	private static let southWestLatitudeKey = "south_west_lat"
	private static let southWestLongitudeKey = "south_west_lon"
	private static let northEastLatitudeKey = "north_east_lat"
	private static let northEastLongitudeKey = "north_east_lon"
	static let fileLocationKey = "fileLocation"
	static let imageURLKey = "image_url"

	convenience init?(_ serialized: SerializedRepresentation) {
		
		guard let southWestLat = serialized[Map.southWestLatitudeKey] as? Double, let southWestLong = serialized[Map.southWestLongitudeKey] as? Double, let northEastLat = serialized[Map.northEastLatitudeKey] as? Double, let northEastLong = serialized[Map.northEastLongitudeKey] as? Double, let imageURLString = serialized[Map.imageURLKey] as? String, let file = serialized[Map.fileLocationKey] as? String, let lastUpdated = serialized[Map.lastUpdatedKey] as? Int
		else {
			return nil
		}
		
		self.init(fileLocation: file, imageURL: imageURLString, southWestLatitude: southWestLat, southWestLongitude: southWestLong, northEastLatitude: northEastLat, northEastLongitude: northEastLong, lastUpdated: lastUpdated)

	}
	
	func toSerializedRepresentation() -> NSDictionary {
		return [Map.fileLocationKey: fileLocation, Map.imageURLKey: imageURL, Map.lastUpdatedKey: lastUpdated ?? 0,
		        Map.southWestLatitudeKey: southWestCoordinate.latitude, Map.southWestLongitudeKey: southWestCoordinate.longitude,
		        Map.northEastLatitudeKey: northEastCoordinate.latitude, Map.northEastLongitudeKey: northEastCoordinate.longitude]
	}
	func updateWith(_ serialized: SerializedRepresentation) -> Bool {
		// TODO: Implement
		return false
	}
}
