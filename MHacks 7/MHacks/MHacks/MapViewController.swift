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
	@IBOutlet var mapView: GMSMapView!
	@IBOutlet var buttonView: UIView!
	var locations = [Location]()
	{
		didSet {
			buttonView.hidden = locations.count == 0
		}
	}
	
    override func viewDidLoad()
	{
		super.viewDidLoad()
		locations = []
		let camera = GMSCameraPosition.cameraWithLatitude(42.291991,
            longitude: -83.7158780, zoom: 18.0)
		mapView.camera = camera
        mapView.setMinZoom(16.0, maxZoom: 20.0)
		mapView.myLocationEnabled = true
	}
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
		blurView.frame = UIApplication.sharedApplication().statusBarFrame
		self.view.addSubview(blurView)
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
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	@IBAction func clearPins(sender: UIButton)
	{
		locations = []
		mapUpdated()
	}
	
	func mapUpdated(_: NSNotification? = nil)
	{
		dispatch_async(dispatch_get_main_queue(), {
			defer
			{
				if self.locations.count > 0
				{
					var boundBuilder = GMSCoordinateBounds(coordinate: self.locations.first!.coreLocation.coordinate,
						coordinate: self.locations.first!.coreLocation.coordinate)
					for location in self.locations
					{
						let marker = GMSMarker(position: location.coreLocation.coordinate)
						marker.tappable = false
						marker.map = self.mapView
						boundBuilder = boundBuilder.includingCoordinate(location.coreLocation.coordinate)
					}
					
					CATransaction.begin()
					CATransaction.setValue(0.85, forKeyPath: kCATransactionAnimationDuration)
					self.mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(boundBuilder, withPadding: 100))
					CATransaction.commit()
				}
			}
			self.mapView.clear()
			guard let overlay = APIManager.sharedManager.map?.overlay
				else
			{
				return
			}
			overlay.map = self.mapView
		})
	}
}
