//
//  CircularProgressIndicator.swift
//  MHacks
//
//  Created by Russell Ladd on 11/12/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit
import QuartzCore

class CircularProgressIndicator: UIView {
    
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
        
        trackLayer.fillColor = nil
        
        progressLayer.fillColor = nil
        progressLayer.lineCap = kCALineCapRound
        
        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
        
        updateProgressLayerColor()
    }
    
    // MARK: Layers
    
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    
    private func updateTrackLayerColor() {
        trackLayer.strokeColor = (trackColor ?? tintColor.colorWithAlphaComponent(0.1)).CGColor
    }
    
    private func updateProgressLayerColor() {
        progressLayer.strokeColor = (progressColor ?? tintColor).CGColor
    }
    
    private func updateLayerLineWidths() {
        
        trackLayer.lineWidth = lineWidth
        progressLayer.lineWidth = lineWidth
    }
    
    // MARK: Properties
    
    var progress: Double = 1.0 {
        didSet {
            // Small number is to ensure a path is always stroked
            progress = min(max(0.000001, progress), 1.0)
            
            progressLayer.strokeEnd = CGFloat(progress)
        }
    }
    
    var lineWidth: CGFloat = 30.0 {
        didSet {
            updateLayerLineWidths()
        }
    }
    
    var trackColor: UIColor? {
        didSet {
            updateTrackLayerColor()
        }
    }
    
    var progressColor: UIColor? {
        didSet {
            updateProgressLayerColor()
        }
    }
    
    // MARK: Tint color
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        updateProgressLayerColor()
        updateTrackLayerColor()
    }
    
    // MARK: Layout
    
    override func layoutSublayersOfLayer(layer: CALayer!) {
        super.layoutSublayersOfLayer(layer)
        
        trackLayer.frame = bounds
        progressLayer.frame = bounds
        
        let circleRect = bounds.rectByInsetting(dx: lineWidth / 2.0, dy: lineWidth / 2.0)
        
        trackLayer.path = UIBezierPath(ovalInRect: circleRect).CGPath
        
        let circleCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let startAngle = CGFloat(0.0 - M_PI_2)
        let endAngle = CGFloat(2.0 * M_PI - M_PI_2)
        
        let progressPath = UIBezierPath(arcCenter: circleCenter, radius: (bounds.width - lineWidth) / 2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        progressLayer.path = progressPath.CGPath
    }
}
