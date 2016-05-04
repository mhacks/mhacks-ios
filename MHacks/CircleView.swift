//
//  CircleView.swift
//  MHacks
//
//  Created by Russell Ladd on 5/3/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class CircleView: UIView {
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        
        NSLayoutConstraint.activateConstraints([
            widthAnchor.constraintEqualToAnchor(heightAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        
        layer.addSublayer(shapeLayer)
        
        updatePath()
        updateFillColor()
        updateStrokeColor()
        updateStrokeWidth()
    }
    
    // MARK: Shape layer
    
    let shapeLayer = CAShapeLayer()
    
    // MARK: Properties
    
    override var bounds: CGRect {
        didSet {
            updatePath()
        }
    }
    
    var fillColor: UIColor? = UIColor.blackColor() {
        didSet {
            updateFillColor()
        }
    }
    
    var strokeWidth: CGFloat = 1.0 {
        didSet {
            updateStrokeWidth()
        }
    }
    
    var strokeColor: UIColor? {
        didSet {
            updateStrokeColor()
        }
    }
    
    // MARK: Shape layer
    
    private func updatePath() {
        shapeLayer.path = UIBezierPath(ovalInRect: bounds).CGPath
    }
    
    private func updateFillColor() {
        shapeLayer.fillColor = fillColor?.CGColor
    }
    
    private func updateStrokeColor() {
        shapeLayer.strokeColor = strokeColor?.CGColor
    }
    
    private func updateStrokeWidth() {
        shapeLayer.lineWidth = strokeWidth
    }
}
