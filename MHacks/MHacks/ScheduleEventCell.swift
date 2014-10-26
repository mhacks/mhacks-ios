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
    
    var color: UIColor = UIColor.clearColor() {
        didSet {
            bodyView.backgroundColor = bodyColorForColor(color)
            leaderBar.backgroundColor = color
        }
    }
    
    func bodyColorForColor(color: UIColor) -> UIColor {
        
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return UIColor(hue: hue, saturation: saturation * 0.25, brightness: brightness, alpha: alpha)
    }
    
    // MARK: Dynamic layout
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        bodyViewTopConstraint.constant = ScheduleHourSeparator.separatorHeightInTraitCollection(traitCollection)
        leaderBarTopConstraint.constant = ScheduleHourSeparator.separatorHeightInTraitCollection(traitCollection)
    }
}
