//
//  Geometry.swift
//  MHacks
//
//  Created by Russell Ladd on 12/10/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

struct Geometry {
    
    static let Separation: CGFloat = 15.0
    
    static let Insets = UIEdgeInsets(top: Separation, left: Separation, bottom: Separation, right: Separation)
    
    // Returns 1.0 if the trait collection's display scale is undefined
    static func hairlineWidthInTraitCollection(collection: UITraitCollection) -> CGFloat {
        return 1.0 / (collection.displayScale == 0.0 ? 1.0 : collection.displayScale)
    }
}
