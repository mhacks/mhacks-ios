//
//  NorthCampusOverlayRendererClass.swift
//  MHacks
//
//  Created by Kyle Zappitell on 3/12/17.
//  Copyright © 2017 MHacks. All rights reserved.
//

import Foundation
import MapKit

// -- Custom Class for Render that Utilizes a UIImage for an Overlay -- //

class NCMapRender: MKOverlayRenderer {
    
    var overlayImage: UIImage
    
    init(img: UIImage, aOverlay: MKOverlay) {
        self.overlayImage = img
        super.init(overlay: aOverlay)
    }
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let image = overlayImage.cgImage
        
        let theMapRect = overlay.boundingMapRect
        let aCGRect = rect(for: theMapRect)
        
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -aCGRect.size.height)
        context.draw(image!, in: aCGRect)
    }
}
