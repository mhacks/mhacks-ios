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

    @IBOutlet var title: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var message: UITextView!
	@IBOutlet var colorView: UIView!
	@IBOutlet var sponsored: UILabel!
	@IBOutlet var unapproved: UILabel!

    // MARK: Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()

		colorView?.layer.cornerRadius = 1.0

		message?.textContainer.lineFragmentPadding = 0
		message?.textContainerInset = .zero
		message?.delegate = self
		
		sponsored?.layer.cornerRadius = 4.0
		sponsored?.clipsToBounds = true
		
		unapproved?.layer.cornerRadius = 4.0
		unapproved?.clipsToBounds = true
    }
}
extension AnnouncementCell: UITextViewDelegate
{
	func textViewDidChangeSelection(_ textView: UITextView) {
		if textView.selectedRange.length > 0
		{
			textView.selectedRange.length = 0
		}
	}
}
