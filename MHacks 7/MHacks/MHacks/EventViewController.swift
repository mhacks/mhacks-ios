//
//  EventViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 9/30/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class EventViewController: UIViewController {
    
    // MARK: Model
    
    var event: Event? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: Date interval formatter
    
    let dateIntervalFormatter: NSDateIntervalFormatter = {
        
        let formatter = NSDateIntervalFormatter()
        
        formatter.dateTemplate = "EEEEdMMMM h:mm a"
        
        return formatter
    }()
    
    // MARK: View
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layoutMargins = Geometry.Insets
		updateViews()
    }
    
    func updateViews() {
        
        if !isViewLoaded() {
            return
        }
        
        if let event = event {
            
            titleLabel.text = event.name
            subtitleLabel.text = event.category.description + " | " + event.locationsDescription
            colorView.backgroundColor = event.category.color
			colorView.layer.cornerRadius = colorView.frame.width / 2
            descriptionLabel.text = event.information
            dateLabel.text = dateIntervalFormatter.stringFromDate(event.startDate, toDate: event.endDate)
        }
    }
}
