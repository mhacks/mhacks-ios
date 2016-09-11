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
	@IBOutlet var dateLabel: UILabel!
	
	weak var delegate: ChangingHeightCellDelegate?
	var expanded = false
	{
		didSet {
			delegate?.cell(self, didChangeSize: CGSize(width: frame.width, height: rowHeight))
		}
	}
	
	let dateFormatter = { () -> DateFormatter in
		let dF = DateFormatter()
		dF.dateFormat = "MMM dd ' at 'HH:mm"
		return dF
	}()
	
	var rowHeight: CGFloat {
		return 261.0 - (expanded ? 0 : datePicker.frame.height + 8.0)
	}
	override func awakeFromNib() {
		super.awakeFromNib()
		datePicker.addTarget(self, action: #selector(DatePickerCell.dateChanged(_:)), for: .valueChanged)
	}
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
        // Configure the view for the selected state
    }
	func dateChanged(_ sender: UIDatePicker)
	{
		dateLabel.text = dateFormatter.string(from: datePicker.date)
	}
}

