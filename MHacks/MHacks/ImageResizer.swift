//
//  ImageResizer.swift
//  MHacks
//
//  Created by Russell Ladd on 8/31/15.
//  Copyright (c) 2015 MHacks. All rights reserved.
//

import UIKit
import AVFoundation

extension UIImage {
    
    func resizedImageWithSize(size: CGSize) -> UIImage {
        
        let rect = AVMakeRectWithAspectRatioInsideRect(self.size, CGRect(origin: CGPointZero, size: size))
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), CGInterpolationQuality.High)
        
        drawInRect(rect)
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
