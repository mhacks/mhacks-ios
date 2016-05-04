//
//  ScheduleNowLabel.swift
//  MHacks
//
//  Created by Russell Ladd on 5/3/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class ScheduleNowLabel: UICollectionReusableView {
    
    @IBOutlet weak var label: UILabel!
    let circleView = CircleView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        circleView.fillColor = UIColor.redColor()
        circleView.strokeColor = UIColor.whiteColor()
        
        addSubview(circleView)
        
        NSLayoutConstraint.activateConstraints([
            circleView.heightAnchor.constraintEqualToConstant(8.0),
            circleView.centerXAnchor.constraintEqualToAnchor(label.trailingAnchor, constant: 8.0),
            circleView.centerYAnchor.constraintEqualToAnchor(centerYAnchor)
        ])
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        circleView.strokeWidth = Geometry.hairlineWidthInTraitCollection(traitCollection)
    }
}
