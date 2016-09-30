//
//  MultilineInputTableViewCell.swift
//  MHacks
//
//  Created by Connor Krupp on 9/26/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class MultilineInputTableViewCell: UITableViewCell {

    let inputTextView = UITextView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stackView = UIStackView(arrangedSubviews: [inputTextView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 15.0
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10.0),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0),
            inputTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60.0)
        ])
        
        inputTextView.textContainerInset = .zero
        inputTextView.textContainer.lineFragmentPadding = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIResponder
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return inputTextView.becomeFirstResponder()
    }
}
