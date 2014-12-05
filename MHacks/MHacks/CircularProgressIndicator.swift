//
//  CircularProgressIndicator.swift
//  MHacks
//
//  Created by Russell Ladd on 11/12/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit
import QuartzCore

/* @IBDesignable */ class CircularProgressIndicator: UIView {
    
    // MARK: Initialization
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    private func commonInit() {
        
        trackView.frame = bounds
        progressView.frame = bounds
        
        trackView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        progressView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        trackView.color = UIColor.whiteColor()
        updateProgressViewColor()
        
        addSubview(trackView)
        addSubview(progressView)
    }
    
    // MARK: Subviews
    
    private let trackView = CircleView()
    private let progressView = CircleView()
    
    func updateProgressViewColor() {
        progressView.color = progressColor ?? tintColor
    }
    
    // MARK: Properties
    
    /* @IBInspectable */ var progress: Double = 1.0 {
        didSet {
            progress = min(max(0.0, progress), 1.0)
            progressView.progress = progress
        }
    }
    
    /* @IBInspectable */ var lineWidth: CGFloat = 20.0 {
        didSet {
            trackView.lineWidth = lineWidth
            progressView.lineWidth = lineWidth
        }
    }
    
    /* @IBInspectable */ var trackColor: UIColor? = UIColor.whiteColor() {
        didSet {
            trackView.color = trackColor
        }
    }
    
    /* @IBInspectable */ var progressColor: UIColor? {
        didSet {
            updateProgressViewColor()
        }
    }
    
    // MARK: Tint color
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        updateProgressViewColor()
    }
}

class CircleView: UIView {
    
    // MARK: Initializers
    
    convenience override init() {
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
        return layer as CAShapeLayer
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
        
        let midX = CGRectGetMidX(bounds)
        let midY = CGRectGetMidY(bounds)
        
        let center = CGPointMake(midX, midY)
        let outerRadius = midX
        let innerRadius = outerRadius - lineWidth
        
        let startAngle = CGFloat(0.0 - M_PI_2)
        let endAngle = CGFloat(progress * 2 * M_PI - M_PI_2)
        
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
