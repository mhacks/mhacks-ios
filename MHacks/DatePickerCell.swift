//
//  DatePickerCell.swift
//  MHacks
//
//  Created by Manav Gabhawala on 2/2/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class DatePickerCell: UITableViewCell {

	let datePicker = UIDatePicker()
	let dateLabel = UILabel()
	
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

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		datePicker.addTarget(self, action: #selector(DatePickerCell.dateChanged(_:)), for: .valueChanged)
		datePicker.isHidden = !expanded
		
		let stackView = UIStackView(arrangedSubviews: [dateLabel, datePicker])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.spacing = 15.0
		stackView.axis = .vertical
		stackView.alignment = .fill
		stackView.distribution = .fill
		
		addSubview(stackView)
		
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
			stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10.0),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0)
		])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func dateChanged(_ sender: UIDatePicker) {
		dateLabel.text = dateFormatter.string(from: datePicker.date)
	}
}

