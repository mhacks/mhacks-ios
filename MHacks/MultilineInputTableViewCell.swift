//
//  MultilineInputTableViewCell.swift
//  MHacks
//
//  Created by Connor Krupp on 9/26/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class MultilineInputTableViewCell: UITableViewCell {

    @IBOutlet weak var inputTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        inputTextView.textContainerInset = .zero
        inputTextView.textContainer.lineFragmentPadding = 0
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
