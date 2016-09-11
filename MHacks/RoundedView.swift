//
//  RoundedView.swift
//  MHacks
//
//  Created by Connor Krupp on 9/11/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
}
