//
//  NorthCampusOverlayClass.swift
//  MHacks
//
//  Created by Kyle Zappitell on 3/12/17.
//  Copyright © 2017 MHacks. All rights reserved.
//

import MapKit
import Foundation

class NCMapOverlay: NSObject, MKOverlay {
    
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    
    init(coord: CLLocationCoordinate2D, MapRect: MKMapRect) {
        coordinate = coord
        boundingMapRect = MapRect
    }
}
