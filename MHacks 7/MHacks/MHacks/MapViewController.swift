//
//  MapViewController.swift
//  MHacks
//
//  Created by Manav Gabhawala on 1/19/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController
{	
	var mapView: GMSMapView!
	var locations = [Location]()
	
    override func viewDidLoad()
	{
		super.viewDidLoad()
		
		let camera = GMSCameraPosition.cameraWithLatitude(42.291921,
            longitude: -83.7158580, zoom: 16)
		mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
		mapView.myLocationEnabled = true
		self.view = mapView
	}
	
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "mapUpdated:", name: APIManager.mapUpdatedNotification, object: nil)
		APIManager.sharedManager.updateMap()
		mapUpdated()
	}
	
	override func viewDidDisappear(animated: Bool)
	{
		super.viewDidDisappear(animated)
		locations = []
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func mapUpdated(_: NSNotification? = nil)
	{
		defer
		{
			if locations.count > 0
			{
				var boundBuilder = GMSCoordinateBounds(coordinate: locations.first!.coreLocation.coordinate,
					coordinate: locations.first!.coreLocation.coordinate)
				for location in locations
				{
					let marker = GMSMarker(position: location.coreLocation.coordinate)
					marker.tappable = false
					marker.map = mapView
					boundBuilder = boundBuilder.includingCoordinate(location.coreLocation.coordinate)
				}
				
				CATransaction.begin()
				CATransaction.setValue(1.0, forKeyPath: kCATransactionAnimationDuration)
				mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(boundBuilder, withPadding: 100))
				CATransaction.commit()
			}
		}
		mapView.clear()
		guard let overlay = APIManager.sharedManager.map?.overlay
		else
		{
			return
		}
		overlay.map = mapView
	}
}
