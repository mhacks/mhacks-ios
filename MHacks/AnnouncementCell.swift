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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var colorView: UIView!
	@IBOutlet weak var sponsoredLabel: UIView!
	@IBOutlet weak var contentStackView: UIStackView!
	
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
        
        super.layoutSubviews()
    }
}
