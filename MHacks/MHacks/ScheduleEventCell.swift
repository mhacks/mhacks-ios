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
    @IBOutlet weak var textLabel: UILabel!
    
    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layoutMargins = UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0)
    }
    
    // MARK: Properties
    
    var color: UIColor = UIColor.clearColor() {
        didSet {
            updateBodyViewBackgroundColor()
            leaderBar.backgroundColor = bodyColorForColor(color, desaturated: false)
            textLabel.textColor = textColorForColor(color)
        }
    }
    
    func bodyColorForColor(color: UIColor, desaturated: Bool) -> UIColor {
        
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let desaturationFactor: CGFloat = desaturated ? 0.25 : 1.0
        let alphaFactor: CGFloat = desaturated ? 0.75 : 0.95
        
        return UIColor(hue: hue, saturation: saturation * desaturationFactor, brightness: brightness, alpha: alpha * alphaFactor)
    }
    
    func textColorForColor(color: UIColor) -> UIColor {
        
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return UIColor(hue: hue, saturation: saturation * 0.8, brightness: brightness * 0.8, alpha: alpha)
    }
    
    func updateBodyViewBackgroundColor() {
        
        let bodyViewHighlighted = highlighted | selected
        
        bodyView.backgroundColor = bodyColorForColor(color, desaturated: !bodyViewHighlighted)
    }
    
    // MARK: Highlight
    
    override var highlighted: Bool {
        didSet {
            updateBodyViewBackgroundColor()
        }
    }
    
    override var selected: Bool {
        didSet {
            updateBodyViewBackgroundColor()
        }
    }
    
    // MARK: Dynamic layout
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        bodyViewTopConstraint.constant = ScheduleHourSeparator.separatorHeightInTraitCollection(traitCollection)
    }
}
