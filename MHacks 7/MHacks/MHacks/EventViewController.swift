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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layoutMargins = Geometry.Insets
		updateViews()
    }
    
    override func viewDidAppear(animated: Bool) {
        if let event = event {
            setMarkersAndCamera(event.locations)
        }
    }
    
    func updateViews() {
        
        if !isViewLoaded() {
            return
        }
        
        if let event = event {
            
            titleLabel.text = event.name
            subtitleLabel.text = event.category.description + " | " + event.locationsDescription
            colorView.backgroundColor = event.category.color
			colorView.layer.cornerRadius = colorView.frame.width / 2
            descriptionLabel.text = event.information
            dateLabel.text = dateIntervalFormatter.stringFromDate(event.startDate, toDate: event.endDate)
            
            updateMap()
        }
    }
	
    func updateMap () {
        let camera = GMSCameraPosition.cameraWithLatitude(42.291921,
            longitude: -83.7158580, zoom: 16)
        mapView.camera = camera
        mapView.myLocationEnabled = true
        mapView.settings.setAllGesturesEnabled(false)
        mapView.setMinZoom(10.0, maxZoom: 18.0)
        
        let northEast = CLLocationCoordinate2D(latitude: 42.294240, longitude: -83.712727)
        let southWest = CLLocationCoordinate2D(latitude: 42.291597, longitude: -83.716529)
        
        let overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)
        
        let icon = UIImage(named: "Map")
        
        let overlay = GMSGroundOverlay(bounds: overlayBounds, icon: icon)
        overlay.bearing = 0
        overlay.map = mapView
    }
    
    func setMarkersAndCamera (var locations: [Location]) {
        let marker = GMSMarker(position: locations[0].coreLocation.coordinate)
        marker.tappable = false
        marker.map = mapView
        var boundBuilder = GMSCoordinateBounds(coordinate: marker.position,
            coordinate: marker.position)
        
        var i: Int
        for i = 1; i < locations.count; ++i {
            let marker = GMSMarker(position: locations[i].coreLocation.coordinate)
            marker.tappable = false
            marker.map = mapView
            boundBuilder = boundBuilder.includingCoordinate(marker.position)
        }
        
        CATransaction.begin()
        CATransaction.setValue(1.0, forKeyPath: kCATransactionAnimationDuration)
        mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(boundBuilder, withPadding: 20))
        CATransaction.commit()
    }
}
