//
//  MapViewController.swift
//  MHacks
//
//  Created by Manav Gabhawala on 1/19/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
	
    override func viewDidLoad()
	{
		super.viewDidLoad()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "mapUpdated:", name: APIManager.mapUpdatedNotification, object: nil)
		
		APIManager.sharedManager.updateMap()
		
		
		let camera = GMSCameraPosition.cameraWithLatitude(42.291921,
            longitude: -83.7158580, zoom: 16)
		let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
		mapView.myLocationEnabled = true
		
		let northEast = CLLocationCoordinate2D(latitude: 42.294240, longitude: -83.712727)
		let southWest = CLLocationCoordinate2D(latitude: 42.291597, longitude: -83.716529)
		
		let overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)
		
		let icon = UIImage(named: "Map")
		
		let overlay = GMSGroundOverlay(bounds: overlayBounds, icon: icon)
		overlay.bearing = 0
		overlay.map = mapView
		
		self.view = mapView
        
        // no marker
	}
	
	func mapUpdated(notification: NSNotification)
	{
		guard let map = APIManager.sharedManager.map
		else
		{
			return
		}
		print(map)
		// TODO: Do things with map
	}
}
