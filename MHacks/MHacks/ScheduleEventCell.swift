//
//  ScheduleEventCell.swift
//  MHacks
//
//  Created by Russell Ladd on 10/13/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class ScheduleEventCell: UICollectionViewCell {
    
    // MARK: Outlets
    
    @IBOutlet private weak var bodyView: UIView!
    @IBOutlet private weak var leaderBar: UIView!
    @IBOutlet private weak var bodyViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leaderBarTopConstraint: NSLayoutConstraint!
    
    // MARK: Properties
    
    var color: UIColor? {
        didSet {
            bodyView.backgroundColor = color
            leaderBar.backgroundColor = color
        }
    }
    
    // MARK: Dynamic layout
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if let window = window {
            bodyViewTopConstraint.constant = 1.0 + ScheduleHourSeparator.separatorHeightInWindow(window)
            leaderBarTopConstraint.constant = 1.0 + ScheduleHourSeparator.separatorHeightInWindow(window)
        }
    }
}
