//
//  NorthCampusOverlayRendererClass.swift
//  MHacks
//
//  Created by Kyle Zappitell on 3/12/17.
//  Copyright © 2017 MHacks. All rights reserved.
//

import Foundation
import MapKit


class NCMapRender: MKOverlayRenderer {
    
    var overlayImage: UIImage
    
    init(img: UIImage, aOverlay: MKOverlay) {
        self.overlayImage = img
        super.init(overlay: aOverlay)
    }
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        //TODO: Build This (Draw Image)
    }
}
