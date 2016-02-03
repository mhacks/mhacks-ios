//
//  TextViewCell.swift
//  MHacks
//
//  Created by Manav Gabhawala on 2/2/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

protocol TextViewCellDelegate : class
{
	func cell(cell: TextViewCell, didChangeSize: CGSize)
}

class TextViewCell: UITableViewCell, UITextViewDelegate
{

	@IBOutlet var textView: UITextView!
	weak var delegate : TextViewCellDelegate?
	
	var rowHeight : CGFloat = 60.0
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		textView.delegate = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
		textView.becomeFirstResponder()
        // Configure the view for the selected state
    }
	func textViewDidChange(textView: UITextView)
	{
		var size = textView.contentSize
		size.height += 16.0
		self.rowHeight = size.height
		self.delegate?.cell(self, didChangeSize: size)
	}
}
