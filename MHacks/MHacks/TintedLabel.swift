//
//  TintedLabel.swift
//  MHacks
//
//  Created by Russell Ladd on 12/10/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class TintedLabel: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        textColor = tintColor
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        textColor = tintColor
    }
}
