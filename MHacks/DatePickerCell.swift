//
//  DatePickerCell.swift
//  MHacks
//
//  Created by Manav Gabhawala on 2/2/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class DatePickerCell: UITableViewCell {

	@IBOutlet var datePicker: UIDatePicker!
	@IBOutlet var dateLabel: UILabel!
	
	var expanded = false {
		didSet {
			datePicker.isHidden = !expanded
		}
	}
	
	let dateFormatter = { () -> DateFormatter in
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMMM dd' at 'h:mm a"
		return dateFormatter
	}()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		datePicker.addTarget(self, action: #selector(DatePickerCell.dateChanged(_:)), for: .valueChanged)
		datePicker.isHidden = !expanded
	}
	
	func dateChanged(_ sender: UIDatePicker) {
		updateDateLabel()
	}
	
	func updateDateLabel() {
		dateLabel.text = dateFormatter.string(from: datePicker.date)
	}
}

