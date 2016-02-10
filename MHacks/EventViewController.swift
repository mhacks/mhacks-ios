//
//  EventViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 9/30/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit
import GoogleMaps

class EventViewController: UIViewController {
    
    // MARK: Model
    
    var event: Event? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: Date interval formatter
    
    let dateIntervalFormatter: NSDateIntervalFormatter = {
        
        let formatter = NSDateIntervalFormatter()
        
        formatter.dateTemplate = "EEEEdMMMM h:mm a"
        
        return formatter
    }()
    
    // MARK: View
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var notifButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notifButton.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
        contentView.layoutMargins = Geometry.Insets
		updateViews()
    }
	
    override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
        updateNotifyButton(event?.notification != nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "mapModelDidUpdate:", name: APIManager.mapUpdatedNotification, object: nil)
		APIManager.sharedManager.updateMap()
		mapModelDidUpdate()
    }
	
	override func viewDidDisappear(animated: Bool) {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	@IBAction func mapWasTapped(sender: UITapGestureRecognizer)
	{
		defer { tabBarController?.selectedIndex = 1 }
		guard let viewControllers = tabBarController?.viewControllers where viewControllers.count > 2
		else
		{
			return
		}
		guard let mapViewController = viewControllers[1] as? MapViewController
		else
		{
			return
		}
		mapViewController.locations = self.event?.locations ?? []
	}
	
	
	func mapModelDidUpdate(_: NSNotification? = nil)
	{
		dispatch_async(dispatch_get_main_queue(), {
			guard let overlay = APIManager.sharedManager.map?.overlay
			else
			{
				return
			}
			self.mapView.clear()
			overlay.bearing = 0
			overlay.map = self.mapView
			self.setMarkersAndCamera(self.event?.locations ?? [])
		})
	}
	
    func updateViews() {
        
        if !isViewLoaded() {
            return
        }
        guard let event = event
		else {
			return
		}
        titleLabel.text = event.name
		subtitleLabel.text = event.category.description + " | " + event.locationsDescription
		colorView.backgroundColor = event.category.color
		colorView.layer.cornerRadius = colorView.frame.width / 2
		descriptionLabel.text = event.information
		dateLabel.text = dateIntervalFormatter.stringFromDate(event.startDate, toDate: event.endDate)
		updateMap()
    }
	
    func updateMap ()
	{
        let camera = GMSCameraPosition.cameraWithLatitude(42.291921, longitude: -83.7158580, zoom: 16)
        mapView.camera = camera
        mapView.myLocationEnabled = true
        mapView.settings.setAllGesturesEnabled(false)
        mapView.setMinZoom(10.0, maxZoom: 18.0)
    }
    
    func setMarkersAndCamera(locations: [Location])
	{
		guard locations.count > 0
		else
		{
			return
		}
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
        CATransaction.setValue(0.85, forKeyPath: kCATransactionAnimationDuration)
        mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(boundBuilder, withPadding: 20))
        CATransaction.commit()
    }
	
    func updateNotifyButton(hasNotification: Bool)
    {   
        if hasNotification
        {
            notifButton.setTitle("Cancel Reminder", forState: UIControlState.Normal)
            notifButton.tintColor = UIColor.redColor()

        }
        else
        {
            notifButton.setTitle("Add Reminder", forState: .Normal)
            notifButton.tintColor = self.view.tintColor
        }
    }
    
    
    @IBAction func notifyMe (sender: UIButton)
	{
		guard let event = event
		else
		{
			return
		}
        if let notif = event.notification
        {
            updateNotifyButton(true)
            UIApplication.sharedApplication().cancelLocalNotification(notif)
        }
        else
        {
            updateNotifyButton(false)
            let notification = UILocalNotification()
            notification.userInfo = ["id": event.ID]
            notification.alertBody = "\(event.name) will start soon at \(event.locationsDescription)"
            notification.fireDate = event.startDate.dateByAddingTimeInterval(-3600)
            
            if #available(iOS 8.2, *) {
                notification.alertTitle = "\(event.name)"
            } else {
                // Fallback on earlier versions
            }
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
	}
}
