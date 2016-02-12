//
//  TextViewCell.swift
//  MHacks
//
//  Created by Manav Gabhawala on 2/2/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

protocol ChangingHeightCellDelegate : class
{
	func cell(cell: UITableViewCell, didChangeSize: CGSize)
}

class TextViewCell: UITableViewCell, UITextViewDelegate
{

	@IBOutlet var textView: UITextView!
	weak var delegate : ChangingHeightCellDelegate?
	
	var rowHeight : CGFloat = 60.0
    override func awakeFromNib() {
        super.awakeFromNib()
		rowHeight = textView.contentSize.height + 16.0
        // Initialization code
		textView.delegate = self
		let container = textView.textContainer
		container.widthTracksTextView = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
        // Configure the view for the selected state
    }
	func textViewDidChange(textView: UITextView)
	{
		var size = textView.contentSize
		size.height += 16.0
		guard size.height != rowHeight
		else
		{
			return
		}
		self.rowHeight = size.height
		self.delegate?.cell(self, didChangeSize: size)
	}
	
}
