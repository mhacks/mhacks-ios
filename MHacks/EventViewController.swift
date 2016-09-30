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
	
	// FIXME: Change to UIPaging view controller like on maps page
	@IBOutlet weak var floorView: UIImageView!
	
	@IBOutlet weak var notifButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notifButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        contentView.layoutMargins = Geometry.Insets
		updateViews()
		updateNotifyButton(event?.notification != nil)
    }
	
    override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateNotifyButton(event?.notification != nil)
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
	
    func updateNotifyButton(_ hasNotification: Bool)
    {   
        if hasNotification
        {
            notifButton.setTitle("Cancel Reminder", for: UIControlState())
            notifButton.tintColor = UIColor.red

        }
        else
        {
            notifButton.setTitle("Add Reminder", for: UIControlState())
            notifButton.tintColor = self.view.tintColor
        }
		if let event = event, event.endDate < Date(timeIntervalSinceNow: 0)
		{
			notifButton.isEnabled = false
		}
		else
		{
			notifButton.isEnabled = true
		}
    }
    
    
    @IBAction func notifyMe (_ sender: UIButton)
	{
		guard let event = event
		else
		{
			return
		}
        if let notif = event.notification
        {
            updateNotifyButton(false)
            UIApplication.shared.cancelLocalNotification(notif)
        }
        else
        {
            updateNotifyButton(true)
            let notification = UILocalNotification()
            notification.userInfo = ["id": event.ID]
            notification.alertBody = "\(event.name) will start soon at \(event.locationsDescription)"
            notification.fireDate = event.startDate.addingTimeInterval(-600) as Date
            notification.soundName = UILocalNotificationDefaultSoundName
			
			notification.alertTitle = "\(event.name)"
			notification.repeatInterval = NSCalendar.Unit.init(rawValue: 0)
			notification.category = ""
            UIApplication.shared.scheduleLocalNotification(notification)
        }
	}
}
