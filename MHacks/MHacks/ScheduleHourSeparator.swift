//
//  ScheduleHourSeparator.swift
//  MHacks
//
//  Created by Russell Ladd on 10/7/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class ScheduleHourSeparator: UICollectionReusableView {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet private weak var separatorHeightConstraint: NSLayoutConstraint!
    
    class func separatorHeightInWindow(window: UIWindow) -> CGFloat {
        return 1.0 / window.screen.scale
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if let window = window {
            separatorHeightConstraint.constant = ScheduleHourSeparator.separatorHeightInWindow(window)
        }
    }
}
