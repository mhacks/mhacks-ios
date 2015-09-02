//
//  ArchView.swift
//  MHacks
//
//  Created by Russell Ladd on 8/31/15.
//  Copyright (c) 2015 MHacks. All rights reserved.
//

import UIKit

class ArchView: UIView {
    
    // MARK: Initializers
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        shapeLayer.fillColor = nil
        
        updatePath()
    }
    
    required init(coder aDecoder: NSCoder) {
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
    
    var lineWidth: CGFloat = 20.0 {
        didSet {
            updatePath()
        }
    }
    
    var progress: Double = 1.0 {
        didSet {
            progress = min(max(0.0, progress), 1.0)
            updatePath()
        }
    }
    
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
        
        let midX = bounds.midX
        let midY = bounds.midY
        
        let center = CGPoint(x: midX, y: midY)
        let outerRadius = midX
        let innerRadius = outerRadius - lineWidth
        
        let startAngle = CGFloat(0.0 - M_PI_2)
        let endAngle = CGFloat(progress * 2.0 * M_PI - M_PI_2)
        
        let topMid = CGPointMake(midX, 0.0)
        let innerEndPoint = CGPoint(x: midX + innerRadius * cos(-endAngle), y: midY + innerRadius * sin(endAngle))
        
        let path = UIBezierPath()
        
        path.moveToPoint(topMid)
        path.addArcWithCenter(center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.addLineToPoint(innerEndPoint)
        path.addArcWithCenter(center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
        path.closePath()
        
        shapeLayer.path = path.CGPath
    }
}
