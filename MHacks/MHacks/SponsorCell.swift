//
//  SponsorCell.swift
//  MHacks
//
//  Created by Ben Oztalay on 11/7/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class SponsorCell: UICollectionViewCell {
    
    // MARK: Outlets
    
    @IBOutlet weak var logoView: UIImageView!
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        logoView.image = nil
    }
}
