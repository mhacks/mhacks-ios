//
//  FloorDescriptionView.swift
//  MHacks
//
//  Created by Russell Ladd on 10/3/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

final class FloorDescriptionView: UICollectionReusableView {
    
    @IBOutlet weak var label: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.preferredMaxLayoutWidth = bounds.width - 30.0
    }
}
