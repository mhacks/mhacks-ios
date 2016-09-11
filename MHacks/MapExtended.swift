//
//  MapExtended.swift
//  MHacks
//
//  Created by Manav Gabhawala on 2/6/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps

// This file is for the GoogleMaps dependency only!
extension Map {
	var overlay: GMSGroundOverlay {
		// FIXME: This should be optional not forced unwrapped
		let overlayBounds = GMSCoordinateBounds(coordinate: southWestCoordinate, coordinate: northEastCoordinate)
		let overlay = GMSGroundOverlay(bounds: overlayBounds, icon: image)
		return overlay!
	}
}
