//
//  Map.swift
//  MHacks
//
//  Created by Manav Gabhawala on 2/5/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

@objc final class Map: NSObject
{
	let fileLocation: String
	let imageURL : String

	private let southWestLatitude : CLLocationDegrees
	private let southWestLongitude : CLLocationDegrees
	
	private let northEastLatitude: CLLocationDegrees
	private let northEastLongitude: CLLocationDegrees
	
	var overlay: GMSGroundOverlay {
		let overlayBounds = GMSCoordinateBounds(coordinate: southWestCoordinate, coordinate: northEastCoordinate)
		let overlay = GMSGroundOverlay(bounds: overlayBounds, icon: image)
		return overlay
	}
	
	private let image: UIImage
	
	private var northEastCoordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: northEastLatitude, longitude: northEastLongitude)
	}
	
	private var southWestCoordinate: CLLocationCoordinate2D {
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
			self.image = UIImage()
			super.init()
			return nil
		}
		self.image = image
		super.init()
	}
	
	convenience init?(serialized: Serialized)
	{
		guard let southWestLat = serialized.doubleValueForKey(Map.southWestLatitudeKey), let southWestLong = serialized.doubleValueForKey(Map.southWestLongitudeKey), let northEastLat = serialized.doubleValueForKey(Map.northEastLatitudeKey), let northEastLong = serialized.doubleValueForKey(Map.northEastLongitudeKey), let imageURLString = serialized[Map.imageURLKey] as? String, let imageURL = NSURL(string: imageURLString)
		else
		{
			return nil
		}
		var fileLocation = serialized[Map.fileLocationKey] as? String
		if fileLocation == nil
		{
			let semaphore = dispatch_semaphore_create(0)
			let downloadTask = NSURLSession.sharedSession().downloadTaskWithURL(imageURL, completionHandler: { downloadedImage, response, error in
				defer {
					dispatch_semaphore_signal(semaphore)
				}
				guard let downloaded = downloadedImage where error == nil
				else
				{
					NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: error)
					return
				}
				guard let directory = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, .UserDomainMask, true).first
				else
				{
					NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: nil)
					return
				}
				let directoryURL = NSURL(fileURLWithPath: directory, isDirectory: true)
				let fileURL = directoryURL.URLByAppendingPathComponent("map")
				do
				{
					try NSFileManager.defaultManager().moveItemAtURL(downloaded, toURL: fileURL)
					fileLocation = fileURL.absoluteString
				}
				catch
				{
					NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: error as NSError)
				}
			})
			downloadTask.resume()
			dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		}
		guard let file = fileLocation
		else
		{
			return nil
		}
		self.init(fileLocation: file, imageURL: imageURLString, southWestLatitude: southWestLat, southWestLongitude: southWestLong, northEastLatitude: northEastLat, northEastLongitude: northEastLong)
	}
	
	static let fileLocationKey = "fileLocation"
	private static let imageURLKey = "image_url"
	private static let southWestLatitudeKey = "south_west_lat"
	private static let southWestLongitudeKey = "south_west_lon"
	private static let northEastLatitudeKey = "north_east_lat"
	private static let northEastLongitudeKey = "north_east_lon"
	
	static func imageURLFromJSON(JSON: JSONWrapper) -> String?
	{
		return JSON[imageURLKey] as? String
	}
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

