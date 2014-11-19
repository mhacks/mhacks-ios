//
//  AnnouncementCell.swift
//  MHacks
//
//  Created by Russell Ladd on 11/18/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

class AnnouncementCell: UITableViewCell {
    
    // MARK: Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layoutMargins = UIEdgeInsetsMake(8.0, 15.0, 8.0, 15.0)
    }
}
