//
//  MultilineLabel.swift
//  MHacks
//
//  Created by Russell Ladd on 8/31/15.
//  Copyright (c) 2015 MHacks. All rights reserved.
//

import UIKit

class MultilineLabel: UILabel {
    
    override func layoutSubviews() {
        
        preferredMaxLayoutWidth = bounds.width
        
        super.layoutSubviews()
    }
}
