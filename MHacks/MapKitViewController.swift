//
//  MapKitViewController.swift
//  MHacks
//
//  Created by Kyle Zappitell on 3/10/17.
//  Copyright © 2017 MHacks. All rights reserved.
//

import UIKit
import MapKit

class MapKitViewController: UIViewController {
    
    @IBOutlet weak var mapViewObject: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //North Campus Lat/Long
        let startCoord = CLLocationCoordinate2DMake(42.292478, -83.715122)
        let adjustedRegion = MKCoordinateRegionMake(startCoord, MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
        
        mapViewObject.mapType = .satellite
        mapViewObject.showsUserLocation = true
        mapViewObject.setRegion(adjustedRegion, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {

    }
    
}
