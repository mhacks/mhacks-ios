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
	
    override func viewDidLoad() {
		super.viewDidLoad()
		let camera = GMSCameraPosition.cameraWithLatitude(42.291921,
            longitude: -83.7158580, zoom: 16)
		let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
		mapView.myLocationEnabled = true
		self.view = mapView
        
        // no marker
	}
}
