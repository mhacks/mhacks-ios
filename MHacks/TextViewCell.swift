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
	func cell(_ cell: UITableViewCell, didChangeSize: CGSize)
}

class TextViewCell: UITableViewCell, UITextViewDelegate
{
	@IBOutlet var textView: UITextView!
}
