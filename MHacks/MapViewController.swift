//
//  MapViewController.swift
//  MHacks
//
//  Created by Manav Gabhawala on 1/19/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController
{	
	@IBOutlet var mapView: GMSMapView!
	@IBOutlet var buttonView: UIView!
	var blurView: UIVisualEffectView!
	let manager = CLLocationManager()
	
	var locations = [Location]()
	{
		didSet {
			buttonView?.isHidden = locations.count == 0
		}
	}
	
    override func viewDidLoad()
	{
		super.viewDidLoad()
		if locations.isEmpty
		{
			locations = []
		}
		let camera = GMSCameraPosition.camera(withLatitude: 42.291991,
            longitude: -83.7158780, zoom: 17.0)
		mapView.camera = camera
        mapView.setMinZoom(16.0, maxZoom: 20.0)
		blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
		blurView.frame = UIApplication.shared.statusBarFrame
		self.view.addSubview(blurView)
	}

	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
		if CLLocationManager.authorizationStatus() == .notDetermined
		{
			manager.requestWhenInUseAuthorization()
		}
		blurView.frame = UIApplication.shared.statusBarFrame
		NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.mapUpdated(_:)), name: APIManager.MapUpdatedNotification, object: nil)
		APIManager.shared.updateMap()
		mapUpdated()
	}
	
	override func viewDidDisappear(_ animated: Bool)
	{
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self)
	}
	
	@IBAction func clearPins(_ sender: UIButton)
	{
		locations = []
		mapUpdated()
	}
	
	func mapUpdated(_: Notification? = nil)
	{
		DispatchQueue.main.async(execute: {
			defer {
				if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
				{
					self.mapView.isMyLocationEnabled = true
				}
				else
				{
					self.mapView.isMyLocationEnabled = false
				}
			}
			defer
			{
				if self.locations.count > 0
				{
					var boundBuilder = GMSCoordinateBounds(coordinate: self.locations.first!.coreLocation.coordinate,
						coordinate: self.locations.first!.coreLocation.coordinate)
					for location in self.locations
					{
						let marker = GMSMarker(position: location.coreLocation.coordinate)
						marker?.isTappable = false
						marker?.map = self.mapView
						boundBuilder = boundBuilder?.includingCoordinate(location.coreLocation.coordinate)
					}
                    
                    var camera: GMSCameraPosition?
                    if self.locations.count == 1 {
                        let coor = self.locations.first!.coreLocation.coordinate
                        camera = GMSCameraPosition.camera(withLatitude: coor.latitude,
                            longitude: coor.longitude, zoom: 18.0)
                    }
                    
                    CATransaction.begin()
                    CATransaction.setValue(0.85, forKeyPath: kCATransactionAnimationDuration)
                    
                    if self.locations.count == 1 {
                        self.mapView.animate(to: camera)
                    } else {
                        self.mapView.animate(with: GMSCameraUpdate.fit(boundBuilder,
                            withPadding: 100.0))
                    }
                    CATransaction.commit()
				}
			}
			self.mapView.clear()
			let overlay = APIManager.shared.map.overlay
			overlay.map = self.mapView
		})
	}
}

