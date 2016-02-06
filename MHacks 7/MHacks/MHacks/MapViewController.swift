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
	weak var mapView: GMSMapView!
	
	
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
		guard let overlay = APIManager.sharedManager.map?.overlay
		else
		{
			return
		}
		mapView.clear()
		overlay.map = mapView
	}
	
	override func viewDidDisappear(animated: Bool)
	{
		super.viewDidDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func mapUpdated(notification: NSNotification)
	{
		guard let overlay = APIManager.sharedManager.map?.overlay
		else
		{
			return
		}
		mapView.clear()
		overlay.map = mapView
	}
}
