//
//  MapKitViewController.swift
//  MHacks
//
//  Created by Kyle Zappitell on 3/10/17.
//  Copyright © 2017 MHacks. All rights reserved.
//

import UIKit
import MapKit

class MapKitViewController: UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var mapViewObject: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //North Campus Lat/Long
        let startCoord = CLLocationCoordinate2DMake(42.292478, -83.715122)
        let adjustedRegion = MKCoordinateRegionMake(startCoord, MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
        
        mapViewObject.mapType = .satellite
        mapViewObject.showsUserLocation = true
        mapViewObject.setRegion(adjustedRegion, animated: true)
        
        //TODO: Complete The NCOverlayRender Class
        
        //These Elements will Be Grabbed from API
        //MKMapRect
        //CLLocationCoordinate2D
        
        //let MapOverlay: NCMapOverlay = NCMapOverlay(coord: <#T##CLLocationCoordinate2D#>, MapRect: <#T##MKMapRect#>)
        //mapViewObject.add(MapOverlay)
        
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
            
            print(northWestCoordinate, southEastCoordinate)
            
            // PUT YOUR OVERLAY CODE HERE
        }
    }
}
