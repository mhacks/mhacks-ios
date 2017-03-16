//
//  IndoorFloorCell.swift
//  MHacks
//
//  Created by Connor Krupp on 3/16/17.
//  Copyright © 2017 MHacks. All rights reserved.
//

import UIKit
import MapKit

final class IndoorFloorCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard super.point(inside: point, with: event)
            else { return false }
        
        return alphaFromPoint(point: point) >= 0.8
    }
}
