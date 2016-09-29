//
//  TextFieldCell.swift
//  MHacks
//
//  Created by Manav Gabhawala on 2/2/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		
		labelWidthConstraint = label.widthAnchor.constraint(equalToConstant: 88.0)
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		let stackView = UIStackView(arrangedSubviews: [label, textField])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.spacing = 15.0
		
		addSubview(stackView)
		
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15.0),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15.0),
			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
			labelWidthConstraint
			])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	let label = UILabel()
	
	let textField = UITextField()
	
	let labelWidthConstraint: NSLayoutConstraint
}
