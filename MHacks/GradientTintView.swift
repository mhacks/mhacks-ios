//
//  GradientTintView.swift
//  MHacks
//
//  Created by Russell Ladd on 9/15/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

final class GradientTintView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        updateGradientColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tintColorDidChange() {
        updateGradientColors()
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    func updateGradientColors() {
        
        func lightened(color: UIColor, by changeInBrightness: CGFloat) -> UIColor {
            
            var h: CGFloat = 0.0
            var s: CGFloat = 0.0
            var b: CGFloat = 0.0
            var a: CGFloat = 0.0
            
            color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            
            b += changeInBrightness
            
            return UIColor(hue: h, saturation: s, brightness: b, alpha: a)
        }
        
        let topColor = tintColor!
        let bottomColor = lightened(color: tintColor, by: -0.1)
        
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
    }
}
