//
//  TextFieldCell.swift
//  MHacks
//
//  Created by Manav Gabhawala on 2/2/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {

	@IBOutlet var textField: UITextField!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
}
