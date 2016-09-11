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
    
    @IBOutlet fileprivate weak var bodyView: UIView!
    @IBOutlet fileprivate weak var leaderBar: UIView!
    @IBOutlet fileprivate weak var bodyViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var detailTextLabel: UILabel!
    
    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layoutMargins = UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0)
    }
    
    // MARK: Properties
    
    var color: UIColor = UIColor.clear {
        didSet {
            updateBodyViewBackgroundColor()
            leaderBar.backgroundColor = bodyColorForColor(color, desaturated: false)
            
            let textColor = textColorForColor(color)
            
            textLabel.textColor = textColor
            detailTextLabel.textColor = textColor
        }
    }
        
    func textColorForColor(_ color: UIColor) -> UIColor {
        
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness * 0.8, alpha: alpha)
    }
    
    func updateBodyViewBackgroundColor() {
        
        let bodyViewHighlighted = isHighlighted || isSelected
        
        bodyView.backgroundColor = bodyColorForColor(color, desaturated: !bodyViewHighlighted)
    }
    
    // MARK: Highlight
    
    override var isHighlighted: Bool {
        didSet {
            updateBodyViewBackgroundColor()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            updateBodyViewBackgroundColor()
        }
    }
    
    // MARK: Dynamic layout
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        bodyViewTopConstraint.constant = Geometry.hairlineWidthInTraitCollection(traitCollection)
    }
}

// Quick and dirty class to not draw any text if there's not enough room
// Used by detailTextLabel so it disappears completely if textLabel gets too long (as opposed to clipping)
// A more elegant solution would be desirable
class DisappearingLabel: UILabel {
    
    override func draw(_ rect: CGRect) {
        
        if abs(bounds.height - intrinsicContentSize.height) <= 0.000001 {
            super.draw(rect)
        }
    }
}
