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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        
        trackLayer.fillColor = nil
        
        progressLayer.fillColor = nil
        progressLayer.lineCap = kCALineCapRound
        
        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
		
		updateTrackLayerColor()
        updateProgressLayerColor()
    }
    
    // MARK: Layers
    
    fileprivate let trackLayer = CAShapeLayer()
    fileprivate let progressLayer = CAShapeLayer()
    
    fileprivate func updateTrackLayerColor() {
        trackLayer.strokeColor = (trackColor ?? tintColor.withAlphaComponent(0.1)).cgColor
    }
    
    fileprivate func updateProgressLayerColor() {
        progressLayer.strokeColor = (progressColor ?? tintColor).cgColor
    }
    
    fileprivate func updateLayerLineWidths() {
        
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
	
	func setProgress(_ progress: Double, animated: Bool) {
		
		let oldProgress = self.progress
		
		self.progress = progress
		
		if animated {
			
			let animation = CABasicAnimation(keyPath: "strokeEnd")
			animation.fromValue = oldProgress
			animation.toValue = min(max(0.000001, progress), 1.0)
			animation.duration = 1.0
			animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
			
			progressLayer.add(animation, forKey: "strokeEnd")
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
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        trackLayer.frame = bounds
        progressLayer.frame = bounds
        
        let circleRect = bounds.insetBy(dx: lineWidth / 2.0, dy: lineWidth / 2.0)
        
        trackLayer.path = UIBezierPath(ovalIn: circleRect).cgPath
        
        let circleCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let startAngle = CGFloat(0.0 - .pi / 2)
        let endAngle = CGFloat(2.0 * .pi - .pi / 2)
        
        let progressPath = UIBezierPath(arcCenter: circleCenter, radius: (bounds.width - lineWidth) / 2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        progressLayer.path = progressPath.cgPath
	}
}
