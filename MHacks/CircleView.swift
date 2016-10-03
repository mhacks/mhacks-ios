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
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        
        layer.addSublayer(shapeLayer)
        
        updatePath()
        updateFillColor()
        updateStrokeColor()
        updateStrokeWidth()
    }
    
    // MARK: Shape layer
    
    let shapeLayer = CAShapeLayer()
    
    // MARK: Tint color
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        updateFillColor()
    }
    
    // MARK: Properties
    
    override var bounds: CGRect {
        didSet {
            updatePath()
        }
    }
    
    var fillColor: UIColor? = UIColor.black {
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
    
    fileprivate func updatePath() {
        shapeLayer.path = UIBezierPath(ovalIn: bounds).cgPath
    }
    
    fileprivate func updateFillColor() {
        shapeLayer.fillColor = (fillColor ?? tintColor).cgColor
    }
    
    fileprivate func updateStrokeColor() {
        shapeLayer.strokeColor = strokeColor?.cgColor
    }
    
    fileprivate func updateStrokeWidth() {
        shapeLayer.lineWidth = strokeWidth
    }
}
