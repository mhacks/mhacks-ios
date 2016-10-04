//
//  CategoryCell.swift
//  MHacks
//
//  Created by Manav Gabhawala on 2/6/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class CategoryCell : UITableViewCell
{
	@IBOutlet var colorView: CircleView!
	@IBOutlet var categoryLabel: UILabel!
	
	let switchControl = UISwitch()
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.accessoryView = switchControl
		
		switchControl.onTintColor = tintColor
	}
	
	override func tintColorDidChange() {
		switchControl.onTintColor = tintColor
	}
}

// Same as CategoryCell without the UISwitch()
class CategoryPickerCell : UITableViewCell
{
	@IBOutlet var colorView: CircleView!
	@IBOutlet var categoryLabel: UILabel!
}
