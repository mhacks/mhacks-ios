//
//  MapKitViewController.swift
//  MHacks
//
//  Created by Kyle Zappitell on 3/10/17.
//  Copyright © 2017 MHacks. All rights reserved.
//

import UIKit
import MapKit

class MapKitViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapViewObject: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewObject.delegate = self
        self.layoutMapOverlay()
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
        let OverlayImage: UIImage = #imageLiteral(resourceName: "grand-map")
        let render: NCMapRender = NCMapRender(img: OverlayImage, aOverlay: overlay);
        
        return render
    }
    
    func floorsUpdated(_ : Notification) {
        
        DispatchQueue.main.async {
            
            if self.isViewLoaded {
                self.layoutMapOverlay()
            }
        }
    }
    
    func layoutMapOverlay() {
        if let floor = APIManager.shared.floors.first {
            let northWestCoordinate = floor.northWestCoordinate
            let southEastCoordinate = floor.southEastCoordinate
            
            //Hard Coded Lat/Long for Testing
            // let northWestCoordinate = CLLocationCoordinate2D(latitude: 42.291820, longitude: -83.716611)
            // let southEastCoordinate = CLLocationCoordinate2D(latitude: 42.293530, longitude: -83.713641)
            
            print(northWestCoordinate, southEastCoordinate)
            
            //-- OVERLAY CODE --//
            let p1 = MKMapPointForCoordinate(northWestCoordinate);
            let p2 = MKMapPointForCoordinate(southEastCoordinate);
            let theSquare: MKMapRect = MKMapRectMake(p1.x, p2.y, fabs(p1.x-p2.x), fabs(p1.y-p2.y))
            let theMidPoint: CLLocationCoordinate2D = CLLocationCoordinate2D(
                latitude: (northWestCoordinate.latitude + southEastCoordinate.latitude)/2,
                longitude: (northWestCoordinate.longitude + southEastCoordinate.longitude)/2)
            
            let MapOverlay: NCMapOverlay = NCMapOverlay(coord: theMidPoint, MapRect: theSquare)
            mapViewObject.add(MapOverlay)
            
            // -- North Campus Lat/Long (Set Frame) -- //
            let startCoord = theMidPoint
            let adjustedRegion = MKCoordinateRegionMake(startCoord, MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
            
            // -- Map Settings -- //
            mapViewObject.mapType = .standard
            mapViewObject.showsUserLocation = true
            mapViewObject.setRegion(adjustedRegion, animated: false)
        }
    }
}
