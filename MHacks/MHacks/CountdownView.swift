//
//  CountdownView.swift
//  MHacks
//
//  Created by Ben Oztalay on 10/13/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class CountdownView: UIView {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        let countdownItemsQuery = PFQuery(className: "CountdownItem")
        countdownItemsQuery.findObjectsInBackgroundWithBlock { objects, error in
            if let error = error {
                println(error)
                return
            }
            
            var nextCountdownItem: NSDate?
            
            if let objects = objects {
                for object in objects {
                    println(object["title"])
                }
            }
        }
    }

}
