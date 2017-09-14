//
//  EventViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 9/30/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit
import MapKit

class EventViewController: UIViewController, MKMapViewDelegate {
	
	// MARK: Model
	
	var event: Event? {
		didSet {
			updateViews()
		}
	}
	
	var overlayImage: UIImage?
	let locationService = CLLocationManager()
	
	// MARK: Date interval formatter
	
	let dateIntervalFormatter: DateIntervalFormatter = {
		
		let formatter = DateIntervalFormatter()
		
		formatter.dateTemplate = "EEEEdMMMM h:mm a"
		
		return formatter
	}()
	
	// MARK: Views
	
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var subtitleLabel: UILabel!
	@IBOutlet var colorView: CircleView!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var dateLabel: UILabel!
	
	@IBOutlet var locationsView: UIStackView!
	
	@IBOutlet var mapView: MKMapView!
	
	final class DoubleLabel: UIStackView {
		
		init() {
			super.init(frame: CGRect.zero)
			
			addArrangedSubview(titleLabel)
			addArrangedSubview(textLabel)
			
			axis = .horizontal
			spacing = 5.0
			
			titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
			textLabel.font = UIFont.preferredFont(forTextStyle: .body)
			
			titleLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow + 1, for: .horizontal)
			
			textLabel.textColor = UIColor(white: 0.5, alpha: 1.0)
		}
		
		required init(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		let titleLabel = UILabel()
		let textLabel = UILabel()
	}
	
	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		updateViews()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		NotificationCenter.default.addObserver(self, selector: #selector(floorsUpdated), name: APIManager.FloorsUpdatedNotification, object: nil)
		
		//APIManager.shared.updateFloors()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		NotificationCenter.default.removeObserver(self, name: APIManager.FloorsUpdatedNotification, object: nil)
	}
	
	// MARK: Notifications
	
	func floorsUpdated(_ notification: Notification) {
		
		DispatchQueue.main.async {
			self.updateViews()
			
		}
	}
	
	// MARK: Update views
	
	func updateViews() {
		
		guard isViewLoaded, let event = event else {
			return
		}
		
		titleLabel.text = event.name
		subtitleLabel.text = event.category.description
		subtitleLabel.textColor = event.category.color
		colorView.fillColor = event.category.color
		descriptionLabel.text = event.description
		dateLabel.text = dateIntervalFormatter.string(from: event.startDate, to: event.endDate)
		
		for subview in locationsView.arrangedSubviews {
			subview.removeFromSuperview()
		}
		
		if let location = event.location {
			let locationLabel = DoubleLabel()
			
			locationLabel.titleLabel.text = location.name
			locationLabel.textLabel.text = nil
			
			locationsView.addArrangedSubview(locationLabel)
		}

		
		guard let floor = APIManager.shared.floors.first else { return }
		
        self.mapView.layer.cornerRadius = 10
        self.mapView.layer.borderColor = UIColor.lightGray.cgColor
        self.mapView.layer.borderWidth = Geometry.hairlineWidthInTraitCollection(self.traitCollection)
		
		floor.retrieveImage { image in
			DispatchQueue.main.async {
				self.layoutMapOverlay(image: image, northWestCoordinate: floor.northWestCoordinate, southEastCoordinate: floor.southEastCoordinate)
			}
		}

	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		if let overlayImage = self.overlayImage {
			return ImageOverlayRenderer(image: overlayImage, overlay: overlay)
		}
		
		// We should never get to here because we dont add the overlay until after the image is loaded
		
		print("Failed to load Overlay Image")
		return MKOverlayRenderer()
	}
	
	func layoutMapOverlay(image: UIImage, northWestCoordinate: CLLocationCoordinate2D, southEastCoordinate: CLLocationCoordinate2D) {
		
		self.mapView.delegate = self
		self.overlayImage = image
		
		let nwMapPoint = MKMapPointForCoordinate(northWestCoordinate)
		let seMapPoint = MKMapPointForCoordinate(southEastCoordinate)
		
		let mapOverlayRectSize = MKMapSize(width: seMapPoint.x - nwMapPoint.x, height: seMapPoint.y - nwMapPoint.y)
		let mapOverlayRect = MKMapRect(origin: nwMapPoint, size: mapOverlayRectSize)
		let midpoint = CLLocationCoordinate2D(
			latitude: (northWestCoordinate.latitude + southEastCoordinate.latitude)/2,
			longitude: (northWestCoordinate.longitude + southEastCoordinate.longitude)/2)
		
		let mapOverlay = MapOverlay(coord: midpoint, mapRect: mapOverlayRect)
		
		self.mapView.add(mapOverlay)
		
		let mapCenter = self.event?.location?.coordinate ?? midpoint
		let adjustedRegion = MKCoordinateRegion(center: mapCenter, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
		
		if let coordinate = self.event?.location?.coordinate {
			let annotation = MKPointAnnotation()
			annotation.coordinate = coordinate
			self.mapView.addAnnotation(annotation)
		}
		
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(shiftToAngledView))
		tapRecognizer.numberOfTapsRequired = 1
		tapRecognizer.numberOfTouchesRequired = 1
		
		self.mapView.mapType = .satelliteFlyover
		self.mapView.isScrollEnabled = false
		self.mapView.isPitchEnabled = false
		self.mapView.isZoomEnabled = false
		self.mapView.isRotateEnabled = false
		self.mapView.showsCompass = false
		self.mapView.setRegion(adjustedRegion, animated: false)
		self.mapView.showsUserLocation = true
		
		self.mapView.addGestureRecognizer(tapRecognizer)
		
		locationService.requestWhenInUseAuthorization()
	}
	
	var isAngled = false
	
	func shiftToAngledView() {
		if let eventLocation = self.event?.location?.coordinate {
			let camera = isAngled ? MKMapCamera(lookingAtCenter: eventLocation, fromDistance: 200, pitch: 0, heading: 0) : MKMapCamera(lookingAtCenter: eventLocation, fromDistance: 200, pitch: 70, heading: 40)
    			self.mapView.setCamera(camera, animated: true)
    			isAngled = !isAngled
		}
	}

}
