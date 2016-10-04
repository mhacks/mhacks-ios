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
    
    let dateIntervalFormatter: DateIntervalFormatter = {
        
        let formatter = DateIntervalFormatter()
        
        formatter.dateTemplate = "EEEEdMMMM h:mm a"
        
        return formatter
    }()
    
    // MARK: Views
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var colorView: CircleView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
	
	// MARK: View life cycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		updateViews()
    }
	
    override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		NotificationCenter.default.addObserver(self, selector: #selector(floorsUpdated), name: APIManager.FloorsUpdatedNotification, object: nil)
		
		APIManager.shared.updateFloors()
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		NotificationCenter.default.removeObserver(self, name: APIManager.FloorsUpdatedNotification, object: nil)
	}
	
	// MARK: Notifications
	
	func floorsUpdated(_ notification: Notification) {
		
		updateViews()
	}
	
    func updateViews() {
        
        if !isViewLoaded {
            return
        }
		
        guard let event = event else {
			return
		}
		
        titleLabel.text = event.name
		subtitleLabel.text = event.category.description + " | " + event.locationsDescription
		colorView.fillColor = event.category.color
		descriptionLabel.text = event.information
		dateLabel.text = dateIntervalFormatter.string(from: event.startDate, to: event.endDate)
		
		// TODO: Put images in floor view
    }
	    
}
