//
//  MapCell.swift
//  MHacks
//
//  Created by Connor Krupp on 3/16/17.
//  Copyright © 2017 MHacks. All rights reserved.
//

import UIKit
import MapKit

final class MapCell: UICollectionViewCell, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    let locationService = CLLocationManager()
    var overlayImage: UIImage?
    var locations: [Location]?
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlayImage = self.overlayImage {
            return ImageOverlayRenderer(image: overlayImage, overlay: overlay)
        }
        
        // We should never get to here because we dont add the overlay until after the image is loaded
        
        print("Failed to load Overlay Image")
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let validLocations = self.locations?.flatMap({ $0.coordinate }) ?? []
        
        for coordinate in validLocations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            self.mapView.addAnnotation(annotation)
        }
    }

    func layoutMapOverlayWithLocations(image: UIImage, northWestCoordinate: CLLocationCoordinate2D, southEastCoordinate: CLLocationCoordinate2D, locations: [Location]?) {
        
        self.mapView.delegate = self
        self.overlayImage = image
        self.locations = locations
        
        let nwMapPoint = MKMapPointForCoordinate(northWestCoordinate)
        let seMapPoint = MKMapPointForCoordinate(southEastCoordinate)
        
        let mapOverlayRectSize = MKMapSize(width: seMapPoint.x - nwMapPoint.x, height: seMapPoint.y - nwMapPoint.y)
        let mapOverlayRect = MKMapRect(origin: nwMapPoint, size: mapOverlayRectSize)
        let midpoint = CLLocationCoordinate2D(
            latitude: (northWestCoordinate.latitude + southEastCoordinate.latitude)/2,
            longitude: (northWestCoordinate.longitude + southEastCoordinate.longitude)/2)
        
        let mapOverlay = MapOverlay(coord: midpoint, mapRect: mapOverlayRect)
        
        self.mapView.add(mapOverlay)
        
        let adjustedRegion = MKCoordinateRegion(center: midpoint, span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
        
        self.mapView.mapType = .standard
        self.mapView.setRegion(adjustedRegion, animated: true)
        self.mapView.showsUserLocation = true
        
        locationService.requestWhenInUseAuthorization()
    }
}
