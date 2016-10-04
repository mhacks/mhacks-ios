//
//  FloorCell.swift
//  MHacks
//
//  Created by Russell Ladd on 10/1/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

final class FloorCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard super.point(inside: point, with: event)
        else { return false }
        
        return alphaFromPoint(point: point) >= 0.8
    }
}
