//
//  MapOverlay.swift
//  MHacks
//
//  Created by Kyle Zappitell on 3/12/17.
//  Copyright © 2017 MHacks. All rights reserved.
//

import Foundation
import MapKit

// -- Generic Class for MKOverlay -- //

class MapOverlay: NSObject, MKOverlay {
    
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    
    init(coord: CLLocationCoordinate2D, mapRect: MKMapRect) {
        coordinate = coord
        boundingMapRect = mapRect
    }
}
