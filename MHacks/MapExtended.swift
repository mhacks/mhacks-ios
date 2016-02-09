//
//  MapExtended.swift
//  MHacks
//
//  Created by Manav Gabhawala on 2/6/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps

extension Map {
	var overlay: GMSGroundOverlay {
		let overlayBounds = GMSCoordinateBounds(coordinate: southWestCoordinate, coordinate: northEastCoordinate)
		let overlay = GMSGroundOverlay(bounds: overlayBounds, icon: image)
		return overlay
	}
}
extension Event {
	
	var notification : UILocalNotification?
	{
		return UIApplication.sharedApplication().scheduledLocalNotifications?.filter { $0.userInfo?["id"] as? String == ID }.first
	}
}