//
//  AnnouncementCell.swift
//  MHacks
//
//  Created by Russell Ladd on 11/18/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class AnnouncementCell: UITableViewCell {
    
    // MARK: Outlets
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
	@IBOutlet var colorView: UIView!
	
	@IBOutlet var sponsoredLabelBackground: UIView!	// Gray box behind label
	@IBOutlet var sponsoredLabelContainer: UIView!	// Blank view for layout
	
    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
		
		colorView.layer.cornerRadius = 1.0
		sponsoredLabelBackground.layer.cornerRadius = 4.0
    }
}
