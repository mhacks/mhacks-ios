//
//  EventViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 9/30/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit
import MapKit

class EventViewController: UIViewController, UICollectionViewDataSource, MKMapViewDelegate, FloorLayoutDelegate {
	
	// MARK: Model
	
	var event: Event? {
		didSet {
			updateViews()
		}
	}
	
	var overlayImage: UIImage?
	
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
	
	@IBOutlet var floorsView: UICollectionView!
	@IBOutlet var floorLayout: FloorLayout!
	
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
		
		floorsView.register(UINib(nibName: "FloorDescription", bundle: nil), forSupplementaryViewOfKind: FloorLayout.SupplementaryViewKind.Description.rawValue, withReuseIdentifier: "Description View")
		floorsView.register(UINib(nibName: "FloorLabel", bundle: nil), forSupplementaryViewOfKind: FloorLayout.SupplementaryViewKind.Label.rawValue, withReuseIdentifier: "Label View")
		
		floorLayout.explodesFromFirstPromotedItem = false
		floorLayout.sectionInsets = UIEdgeInsets(top: 10.0, left: 40.0, bottom: 10.0, right: 40.0)
		floorLayout.labelInset = -32.0
		
		updateViews()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		NotificationCenter.default.addObserver(self, selector: #selector(floorsUpdated), name: APIManager.FloorsUpdatedNotification, object: nil)
		
		APIManager.shared.updateFloors()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		NotificationCenter.default.removeObserver(self, name: APIManager.FloorsUpdatedNotification, object: nil)
	}
	
	// MARK: Notifications
	
	func floorsUpdated(_ notification: Notification) {
		
		updateViews()
	}
	
	// MARK: Update views
	
	func updateViews() {
		
		if !isViewLoaded {
			return
		}
		
		guard let event = event else {
			return
		}
		
		titleLabel.text = event.name
		subtitleLabel.text = event.category.description
		subtitleLabel.textColor = event.category.color
		colorView.fillColor = event.category.color
		descriptionLabel.text = event.information
		dateLabel.text = dateIntervalFormatter.string(from: event.startDate, to: event.endDate)
		
		for subview in locationsView.arrangedSubviews {
			subview.removeFromSuperview()
		}
		
		for location in event.locations {
			
			let locationLabel = DoubleLabel()
			
			if let floor = location.floor {
				
				locationLabel.titleLabel.text = floor.name
				locationLabel.textLabel.text = location.name
				
			} else {
				
				locationLabel.titleLabel.text = location.name
				locationLabel.textLabel.text = nil
			}
			
			locationsView.addArrangedSubview(locationLabel)
		}
		
		var prominentFloors = IndexSet()
		
		for location in event.locations {
			
			if let floor = location.floor, let index = APIManager.shared.floors.index(of: floor) {
				prominentFloors.insert(index)
			}
		}
		
		floorsView.isHidden = prominentFloors.isEmpty
		
		floorLayout.promotedItems = prominentFloors
	}
	
	// MARK: Collection view data source
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return APIManager.shared.floors.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let mapCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Map Cell", for: indexPath) as! MapCell
		
		let floor = APIManager.shared.floors[indexPath.item]
		
		mapCell.mapView.alpha = 0.0
		
		floor.retrieveImage { image in
			DispatchQueue.main.async {
				
				if collectionView.indexPath(for: mapCell) == indexPath {
					mapCell.layoutMapOverlayWithLocations(image: image, northWestCoordinate: floor.northWestCoordinate, southEastCoordinate: floor.southEastCoordinate, locations: self.event?.locations)
					
    				UIView.animate(withDuration: 0.15) {
    					mapCell.mapView.alpha = 1.0
    				}
				}
				
			}
		}
		
		return mapCell
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		let floor = APIManager.shared.floors[indexPath.item]
		
		let view: UICollectionReusableView
		
		switch FloorLayout.SupplementaryViewKind(rawValue: kind)! {
			
		case .Description:
			
			let descriptionView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Description View", for: indexPath) as! FloorDescriptionView
			
			descriptionView.label.text = floor.description
			
			view = descriptionView
			
		case .Label:
			
			let labelView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Label View", for: indexPath) as! FloorLabelView
			
			if floor.name.isEmpty {
				labelView.label.text = nil
			} else {
				labelView.label.text = String(floor.name.characters[floor.name.startIndex])
			}
			
			// Super lame fix to not show floor label when we have one floor
			labelView.isHidden = true
			
			view = labelView
		}
		
		return view
	}
	
	// MARK: Floor layout delegate
	
	func collectionView(_ collectionView: UICollectionView, floorLayout: FloorLayout, offsetFractionForItemAt indexPath: IndexPath) -> CGFloat {
		return CGFloat(APIManager.shared.floors[indexPath.item].offsetFraction)
	}
	
	func collectionView(_ collectionView: UICollectionView, floorLayout: FloorLayout, aspectRatioForItemAt indexPath: IndexPath) -> CGFloat {
		return CGFloat(APIManager.shared.floors[indexPath.item].aspectRatio)
	}
	
	// MARK: MKMapViewDelegate
	
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlayImage = self.overlayImage {
            return ImageOverlayRenderer(image: overlayImage, overlay: overlay)
        }
        
        // We should never get to here because we dont add the overlay until after the image is loaded
        
        print("Failed to load Overlay Image")
        return MKOverlayRenderer()
    }
    
}
