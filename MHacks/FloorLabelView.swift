//
//  FloorLabelView.swift
//  MHacks
//
//  Created by Russell Ladd on 10/3/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

final class FloorLabelView: UICollectionReusableView {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var circleView: CircleView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        circleView.fillColor = UIColor(red: 0.0 / 255.0, green: 169.0 / 255.0, blue: 194.0 / 255.0, alpha: 1.0)
    }
}
