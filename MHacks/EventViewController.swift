//
//  EventViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 9/30/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit
import GoogleMaps
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class EventViewController: UIViewController {
    
    // MARK: Model
    
    var event: Event? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: Date interval formatter
    
    let dateIntervalFormatter: DateIntervalFormatter = {
        
        let formatter = DateIntervalFormatter()
        
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
        notifButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        contentView.layoutMargins = Geometry.Insets
		updateViews()
		updateNotifyButton(event?.notification != nil)
    }
	
    override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if event?.endDate < Date(timeIntervalSinceNow: 0)
		{
			notifButton.isEnabled = false
		}
		else
		{
			notifButton.isEnabled = true
		}
		colorView.layer.cornerRadius = colorView.frame.width / 2
		NotificationCenter.default.addObserver(self, selector: #selector(EventViewController.mapModelDidUpdate(_:)), name: APIManager.MapUpdatedNotification, object: nil)
		APIManager.shared.updateMap()
		var frame = contentView.frame.size
		frame.height += Geometry.Insets.bottom
		(contentView.superview as! UIScrollView).contentSize = frame
		mapModelDidUpdate()
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		NotificationCenter.default.removeObserver(self)
	}
	
	@IBAction func mapWasTapped(_ sender: UITapGestureRecognizer)
	{
		defer { tabBarController?.selectedIndex = 1 }
		guard let viewControllers = tabBarController?.viewControllers , viewControllers.count > 2
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
	
	
	func mapModelDidUpdate(_: Notification? = nil) {
		DispatchQueue.main.async {
			let overlay = APIManager.shared.map.overlay
			self.mapView.clear()
			overlay.bearing = 0
			overlay.map = self.mapView
			self.setMarkersAndCamera(self.event?.locations ?? [])
		}
	}
	
    func updateViews() {
        
        if !isViewLoaded {
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
		dateLabel.text = dateIntervalFormatter.string(from: event.startDate as Date, to: event.endDate as Date)
		updateMap()
    }
	
    func updateMap ()
	{
        let camera = GMSCameraPosition.camera(withLatitude: 42.291921, longitude: -83.7158580, zoom: 16)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        mapView.settings.setAllGesturesEnabled(false)
        mapView.setMinZoom(10.0, maxZoom: 18.0)
    }
    
    func setMarkersAndCamera(_ locations: [Location])
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
			marker?.isTappable = false
			marker?.map = mapView
			boundBuilder = boundBuilder?.includingCoordinate(location.coreLocation.coordinate)
		}
		
        CATransaction.begin()
        CATransaction.setValue(0.85, forKeyPath: kCATransactionAnimationDuration)
        mapView.animate(with: GMSCameraUpdate.fit(boundBuilder, withPadding: 20))
        CATransaction.commit()
    }
	
    func updateNotifyButton(_ hasNotification: Bool)
    {   
        if hasNotification
        {
            notifButton.setTitle("Cancel Reminder", for: UIControlState())
            notifButton.tintColor = UIColor.red

        }
        else
        {
            notifButton.setTitle("Add Reminder", for: UIControlState())
            notifButton.tintColor = self.view.tintColor
        }
    }
    
    
    @IBAction func notifyMe (_ sender: UIButton)
	{
		guard let event = event
		else
		{
			return
		}
        if let notif = event.notification
        {
            updateNotifyButton(false)
            UIApplication.shared.cancelLocalNotification(notif)
        }
        else
        {
            updateNotifyButton(true)
            let notification = UILocalNotification()
            notification.userInfo = ["id": event.ID]
            notification.alertBody = "\(event.name) will start soon at \(event.locationsDescription)"
            notification.fireDate = event.startDate.addingTimeInterval(-600) as Date
            notification.soundName = UILocalNotificationDefaultSoundName
			
			notification.alertTitle = "\(event.name)"
			notification.repeatInterval = NSCalendar.Unit.init(rawValue: 0)
			notification.category = ""
            UIApplication.shared.scheduleLocalNotification(notification)
        }
	}
}
