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
        
        backgroundColor = tintColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tintColorDidChange() {
        backgroundColor = tintColor
    }
}
