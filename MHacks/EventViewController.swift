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
	
    override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		colorView.layer.cornerRadius = colorView.frame.width / 2
		
		// FIXME: Only update if floors cannot be found!
		APIManager.shared.updateFloors()
		
		var frame = contentView.frame.size
		frame.height += Geometry.Insets.bottom
		(contentView.superview as! UIScrollView).contentSize = frame
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		NotificationCenter.default.removeObserver(self)
	}
	
	@IBAction func mapWasTapped(_ sender: UITapGestureRecognizer)
	{
		// TODO: Switch to map tab?
	}
	
	
    func updateViews() {
        
        if !isViewLoaded {
            return
        }
        guard let event = event
		else {
			return
		}
        titleLabel.text = event.name
		subtitleLabel.text = event.category.description + " | " + event.locationsDescription
		colorView.backgroundColor = event.category.color
		colorView.layer.cornerRadius = colorView.frame.width / 2
		descriptionLabel.text = event.information
		dateLabel.text = dateIntervalFormatter.string(from: event.startDate as Date, to: event.endDate as Date)
		// TODO: Put images in floor view
    }
	    
}
