//
//  MapCollectionViewCell.swift
//  MHacks
//
//  Created by Ben Oztalay on 12/3/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class MapCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mapImage: UIImageView!
    
    class func ResuseIdentifier() -> String {
        return "MapCell"
    }
}
