//
//  ShadowView.swift
//  MHacks
//
//  Created by Russell Ladd on 9/12/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

final class ShadowView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
}
