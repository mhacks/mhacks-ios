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
            updateLabels()
        }
    }
    
    // MARK: Date interval formatter
    
    let dateIntervalFormatter: NSDateIntervalFormatter = {
        
        let formatter = NSDateIntervalFormatter()
        
        formatter.dateTemplate = "EEEEdMMMM h:mm a"
        
        return formatter
    }()
    
    // MARK: View
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layoutMargins = UIEdgeInsetsMake(16.0, 16.0, 16.0, 16.0)
        
        updateLabels()
    }
    
    func updateLabels() {
        
        if !isViewLoaded() {
            return
        }
        
        if let event = event {
            
            titleLabel.text = event.name
            subtitleLabel.text = event.category.title + " | " + event.locationsDescription
            descriptionLabel.text = event.description
            dateLabel.text = dateIntervalFormatter.stringFromDate(event.startDate, toDate: event.endDate)
        }
    }
}
