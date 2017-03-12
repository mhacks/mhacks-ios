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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {

    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let OverlayImage: UIImage = #imageLiteral(resourceName: "grand-map")
        let render: NCMapRender = NCMapRender(img: OverlayImage, aOverlay: overlay);
        
        return render
    }
}
