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
        
        circleView.fillColor = UIColor.red
        circleView.strokeColor = UIColor.white
        
        addSubview(circleView)
        
        NSLayoutConstraint.activate([
            circleView.heightAnchor.constraint(equalToConstant: 8.0),
            circleView.centerXAnchor.constraint(equalTo: label.trailingAnchor, constant: 8.0),
            circleView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        circleView.strokeWidth = Geometry.hairlineWidthInTraitCollection(traitCollection)
    }
}
