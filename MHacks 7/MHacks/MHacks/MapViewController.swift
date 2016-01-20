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
	override func viewDidLoad()
	{
		super.viewDidLoad()
		let camera = GMSCameraPosition.cameraWithLatitude(-33.86,
			longitude: 151.20, zoom: 6)
		let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
		mapView.myLocationEnabled = true
		self.view = mapView
		
		let marker = GMSMarker()
		marker.position = CLLocationCoordinate2DMake(-33.86, 151.20)
		marker.title = "Sydney"
		marker.snippet = "Australia"
		marker.map = mapView
	}
}
