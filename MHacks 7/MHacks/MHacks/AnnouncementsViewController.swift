//
//  AnnouncementsViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 11/18/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class AnnouncementsViewController: UITableViewController {
	
	@IBOutlet var composeButton: UIBarButtonItem!
	
    // MARK: Model
	
	private func fetch() {
		refreshControl?.beginRefreshing()
		APIManager.sharedManager.updateAnnouncements()
	}
	
    // MARK: ViewController Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
		refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 100.0
		
    }
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "announcementsUpdated:", name: APIManager.announcementsUpdatedNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "connectionError:", name: APIManager.connectionFailedNotification, object: nil)
		announcementsUpdated() // Just in case.
		fetch()
		if APIManager.sharedManager.canPostAnnouncements()
		{
			composeButton.enabled = true
		}
		else
		{
			composeButton.enabled = false
		}
	}
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	// MARK: - Actions/Notifications
	func refresh(sender: UIRefreshControl)
	{
		fetch()
	}
	func announcementsUpdated(_: NSNotification? = nil)
	{
		dispatch_async(dispatch_get_main_queue(), {
			self.refreshControl?.endRefreshing()
			self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
		})
	}
	func connectionError(notification: NSNotification)
	{
		refreshControl?.endRefreshing()
	}
    
    // MARK: Table View Data
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return APIManager.sharedManager.announcements.count
    }
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath) as! AnnouncementCell
        
        let announcement = APIManager.sharedManager.announcements[indexPath.row]
        
        cell.titleLabel.text = announcement.title
        cell.dateLabel.text = announcement.localizedDate
        cell.messageLabel.text = announcement.message
        
        return cell
    }
	
}
