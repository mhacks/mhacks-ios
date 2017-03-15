//
//  MapViewController.swift
//  MHacks
//
//  Created by Kyle Zappitell on 3/10/17.
//  Copyright © 2017 MHacks. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    var overlayImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(floorsUpdated(_:)), name: APIManager.FloorsUpdatedNotification, object: nil)
        
        APIManager.shared.updateFloors()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: APIManager.FloorsUpdatedNotification, object: nil)
    }
    
    //-- Delegate function for rendering overlay -- //
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlayImage = self.overlayImage {
            return ImageOverlayRenderer(image: overlayImage, overlay: overlay)
        }
        
        // We should never get to here because we dont add the overlay until after the image is loaded
        
        print("Failed to load Overlay Image")
        return MKOverlayRenderer()
    }
    
    func floorsUpdated(_ : Notification) {
        
        DispatchQueue.main.async {
            
            guard self.isViewLoaded, let floor = APIManager.shared.floors.first else { return }
            
            floor.retrieveImage { image in
                DispatchQueue.main.async {
                    self.layoutMapOverlay(image: image, northWestCoordinate: floor.northWestCoordinate, southEastCoordinate: floor.southEastCoordinate)
                }
            }
        }
    }
    
    func layoutMapOverlay(image: UIImage, northWestCoordinate: CLLocationCoordinate2D, southEastCoordinate: CLLocationCoordinate2D) {
        
        self.overlayImage = image
        
        //-- OVERLAY CODE --//
        let nwMapPoint = MKMapPointForCoordinate(northWestCoordinate)
        let seMapPoint = MKMapPointForCoordinate(southEastCoordinate)
        
        let mapOverlayRectSize = MKMapSize(width: seMapPoint.x - nwMapPoint.x, height: nwMapPoint.y - seMapPoint.y)
        let mapOverlayRect = MKMapRect(origin: nwMapPoint, size: mapOverlayRectSize)
        let midpoint = CLLocationCoordinate2D(
            latitude: (northWestCoordinate.latitude + southEastCoordinate.latitude)/2,
            longitude: (northWestCoordinate.longitude + southEastCoordinate.longitude)/2)
        
        let mapOverlay = MapOverlay(coord: midpoint, mapRect: mapOverlayRect)
        
        self.mapView.add(mapOverlay)
        
        // -- North Campus Lat/Long (Set Frame) -- //
        let adjustedRegion = MKCoordinateRegion(center: midpoint, span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006))
        
        // -- Map Settings -- //
        self.mapView.mapType = .standard
        self.mapView.showsUserLocation = true
        self.mapView.setRegion(adjustedRegion, animated: true)
    }
}
