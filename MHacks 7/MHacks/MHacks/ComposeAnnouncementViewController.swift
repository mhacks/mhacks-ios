//
//  ComposeAnnouncementViewController.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/23/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import UIKit


class ComposeAnnouncementViewController: UIViewController {
	@IBOutlet var titleField: UITextField!
	@IBOutlet var messageField: UITextField!
	@IBOutlet var announceAt: UIDatePicker!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		announceAt.minimumDate = NSDate(timeIntervalSinceNow: 0)
		// TODO: Set maximum date
	}
	
	@IBAction func post(_: UIBarButtonItem)
	{
		let announcement = Announcement(title: titleField.text ?? "", message: messageField.text ?? "", date: announceAt.date)
		
		APIManager.sharedManager.postAnnouncement(announcement, completion: { finished in
			// TODO: Pop view controller on success. 
			// Otherwise error message? 
		})
	}
}