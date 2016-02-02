//
//  DatePickerCell.swift
//  MHacks
//
//  Created by Manav Gabhawala on 2/2/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class DatePickerCell: UITableViewCell
{

	@IBOutlet var datePicker: UIDatePicker!

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
        // Configure the view for the selected state
    }

}
