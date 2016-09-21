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
	@IBOutlet var sponsoredLabel: UIView!
	@IBOutlet var contentStackView: UIStackView!
	
    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
		
		dateLabel.font = Announcement.dateFont
        contentView.layoutMargins = UIEdgeInsetsMake(8.0, 15.0, 8.0, 15.0)
    }

	override func layoutSubviews() {
        
        super.layoutSubviews()
        
        titleLabel?.preferredMaxLayoutWidth = titleLabel.frame.width
        messageLabel?.preferredMaxLayoutWidth = messageLabel.frame.width
		
		colorView.layer.cornerRadius = 2
		sponsoredLabel.layer.cornerRadius = 4
        
        super.layoutSubviews()
    }
}
