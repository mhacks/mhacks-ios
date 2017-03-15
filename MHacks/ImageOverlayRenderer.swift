//
//  ImageOverlayRenderer.swift
//  MHacks
//
//  Created by Kyle Zappitell on 3/12/17.
//  Copyright © 2017 MHacks. All rights reserved.
//

import UIKit
import MapKit

// -- Custom Class for Render that Utilizes a UIImage for an Overlay -- //

class ImageOverlayRenderer: MKOverlayRenderer {
    
    var overlayImage: UIImage
    
    init(image: UIImage, overlay: MKOverlay) {
        self.overlayImage = image
        super.init(overlay: overlay)
    }
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let image = overlayImage.cgImage
        
        let mapRect = overlay.boundingMapRect
        let cgRect = rect(for: mapRect)
        
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -cgRect.size.height)
        context.draw(image!, in: cgRect)
    }
}
