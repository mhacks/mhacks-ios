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
	@IBOutlet var sponsoredTextView: UITextView!
	@IBOutlet var unapprovedTextView: UITextView!
	
    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
		
		colorView.layer.cornerRadius = 1.0
		sponsoredTextView?.layer.cornerRadius = 4.0
		sponsoredTextView?.textContainerInset = .zero
		
		unapprovedTextView?.layer.cornerRadius = 4.0
		unapprovedTextView?.textContainerInset = .zero
    }
}
