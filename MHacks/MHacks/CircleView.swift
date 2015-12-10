//
//  CircleView.swift
//  MHacks
//
//  Created by Russell Ladd on 1/3/15.
//  Copyright (c) 2015 MHacks. All rights reserved.
//

import Foundation

class CircleView: UIView {
    
    // MARK: Initializers
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        shapeLayer.fillColor = nil
        
        updatePath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        shapeLayer.fillColor = nil
        
        updatePath()
    }
    
    // MARK: Layer
    
    override class func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }
    
    private var shapeLayer: CAShapeLayer {
        return layer as! CAShapeLayer
    }
    
    // MARK: Properties
    
    var color: UIColor? {
        didSet {
            shapeLayer.fillColor = color?.CGColor
        }
    }
    
    override var frame: CGRect {
        didSet {
            updatePath()
        }
    }
    
    // MARK: Shape layer
    
    func updatePath() {
        shapeLayer.path = UIBezierPath(ovalInRect: bounds).CGPath
    }
}
