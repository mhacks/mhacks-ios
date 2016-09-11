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
    static func hairlineWidthInTraitCollection(_ collection: UITraitCollection) -> CGFloat {
        return 1.0 / (collection.displayScale == 0.0 ? 1.0 : collection.displayScale)
    }
}

extension CGFloat {
    
    func integratedFloatInTraitCollection(_ collection: UITraitCollection) -> CGFloat {
        return (self * collection.displayScale).rounded() / collection.displayScale
    }
}

extension CGRect {
    
    func integratedRectInTraitCollection(_ collection: UITraitCollection) -> CGRect {
        
        let minX = self.minX.integratedFloatInTraitCollection(collection)
        let maxX = self.maxX.integratedFloatInTraitCollection(collection)
        let minY = self.minY.integratedFloatInTraitCollection(collection)
        let maxY = self.maxY.integratedFloatInTraitCollection(collection)
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}
