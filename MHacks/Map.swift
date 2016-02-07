//
//  Map.swift
//  MHacks
//
//  Created by Manav Gabhawala on 2/5/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit
import CoreLocation

@objc final class Map: NSObject
{
	let fileLocation: String
	let imageURL : String

	private let southWestLatitude : CLLocationDegrees
	private let southWestLongitude : CLLocationDegrees
	
	private let northEastLatitude: CLLocationDegrees
	private let northEastLongitude: CLLocationDegrees
	
	
	let image: UIImage
	
	var northEastCoordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: northEastLatitude, longitude: northEastLongitude)
	}
	
	var southWestCoordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: southWestLatitude, longitude: southWestLongitude)
	}
	
	init?(fileLocation: String, imageURL: String, southWestLatitude : CLLocationDegrees, southWestLongitude : CLLocationDegrees, northEastLatitude: CLLocationDegrees, northEastLongitude: CLLocationDegrees)
	{
		self.fileLocation = fileLocation
		self.imageURL = imageURL
		self.southWestLatitude = southWestLatitude
		self.southWestLongitude = southWestLongitude
		self.northEastLatitude = northEastLatitude
		self.northEastLongitude = northEastLongitude
		
		guard let image = UIImage(contentsOfFile: fileLocation)
		else
		{
			let image = UIImage(named: "Map")
			guard !fileLocation.isEmpty && image != nil
			else
			{
				// Debugging
				self.image = image!
				super.init()
				return
			}
			self.image = UIImage()
			super.init()
			return nil
		}
		self.image = image
		super.init()
	}
	
	convenience init?(serialized: Serialized)
	{
		guard let southWestLat = serialized.doubleValueForKey(Map.southWestLatitudeKey), let southWestLong = serialized.doubleValueForKey(Map.southWestLongitudeKey), let northEastLat = serialized.doubleValueForKey(Map.northEastLatitudeKey), let northEastLong = serialized.doubleValueForKey(Map.northEastLongitudeKey), let imageURLString = serialized[Map.imageURLKey] as? String
		else
		{
			return nil
		}
		guard let file = serialized[Map.fileLocationKey] as? String
		else
		{
			self.init(fileLocation: "", imageURL: "", southWestLatitude: 42.291597, southWestLongitude: -83.716529, northEastLatitude: 42.294240, northEastLongitude: -83.712727)
			return
		}
		self.init(fileLocation: file, imageURL: imageURLString, southWestLatitude: southWestLat, southWestLongitude: southWestLong, northEastLatitude: northEastLat, northEastLongitude: northEastLong)
	}
	
	static let fileLocationKey = "fileLocation"
	static let imageURLKey = "image_url"
	private static let southWestLatitudeKey = "south_west_lat"
	private static let southWestLongitudeKey = "south_west_lon"
	private static let northEastLatitudeKey = "north_east_lat"
	private static let northEastLongitudeKey = "north_east_lon"
}
extension Map : JSONCreateable {
	
	@objc func encodeWithCoder(aCoder: NSCoder)
	{
		aCoder.encodeObject(fileLocation, forKey: Map.fileLocationKey)
		aCoder.encodeObject(imageURL, forKey: Map.imageURLKey)
		aCoder.encodeDouble(southWestLatitude, forKey: Map.southWestLatitudeKey)
		aCoder.encodeDouble(southWestLongitude, forKey: Map.southWestLongitudeKey)
		aCoder.encodeDouble(northEastLatitude, forKey: Map.northEastLatitudeKey)
		aCoder.encodeDouble(northEastLongitude, forKey: Map.northEastLongitudeKey)

	}
	@objc convenience init?(coder aDecoder: NSCoder) {
		self.init(serialized: Serialized(coder: aDecoder))
	}
}
func ==(lhs: Map, rhs: Map) -> Bool
{
	return lhs.southWestLatitude == rhs.southWestLatitude && lhs.southWestLongitude == rhs.southWestLongitude && lhs.northEastLatitude == rhs.northEastLatitude && lhs.northEastLongitude == rhs.northEastLongitude && lhs.imageURL == rhs.imageURL
}

