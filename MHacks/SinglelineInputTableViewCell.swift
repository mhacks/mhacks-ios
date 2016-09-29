//
//  SinglelineInputTableViewCell.swift
//  MHacks
//
//  Created by Connor Krupp on 9/26/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class SinglelineInputTableViewCell: UITableViewCell {

    @IBOutlet weak var inputTextField: UITextField!
    
    // MARK: UIResponder
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return inputTextField.becomeFirstResponder()
    }
}
