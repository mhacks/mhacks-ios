//
//  AnnouncementsViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 11/18/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class AnnouncementsViewController: UITableViewController {
	
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
		if APIManager.sharedManager.canPostAnnouncements()
		{
			navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "compose:")
		}
		if APIManager.sharedManager.canEditAnnouncements()
		{
			tableView.allowsSelection = true
			tableView.allowsMultipleSelection = false
		}
		else
		{
			tableView.allowsSelection = false
			tableView.allowsMultipleSelection = false
		}
		if let indexPath = tableView.indexPathForSelectedRow
		{
			transitionCoordinator()?.animateAlongsideTransition({ context in
				self.tableView.deselectRowAtIndexPath(indexPath, animated: animated)
				}, completion: { context in
					if context.isCancelled() {
						self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
					}
			})
		}
		tableView.reloadData()
		fetch()
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
	func announcementsUpdated(notification: NSNotification? = nil)
	{
		dispatch_async(dispatch_get_main_queue(), {
			guard notification?.object != nil
			else
			{
				self.refreshControl?.endRefreshing()
				return
			}
			CATransaction.begin()
			CATransaction.setCompletionBlock({
				self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
			})
			self.refreshControl?.endRefreshing()
			CATransaction.commit()
		})
	}
	func connectionError(notification: NSNotification)
	{
		refreshControl?.endRefreshing()
	}
	
	func compose(sender: UIBarButtonItem)
	{
		guard APIManager.sharedManager.canPostAnnouncements()
		else
		{
			navigationItem.rightBarButtonItem = nil
			return
		}
		let compose = storyboard!.instantiateViewControllerWithIdentifier("ComposeAnnouncementViewController") as! ComposeAnnouncementViewController
		presentViewController(compose, animated: true, completion: nil)
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
		cell.dateLabel.font = Announcement.dateFont
        cell.messageLabel.text = announcement.message
		cell.colorView.layer.borderColor = announcement.category.color.CGColor
		cell.colorView.layer.borderWidth = cell.colorView.frame.width
        return cell
    }
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		if APIManager.sharedManager.canEditAnnouncements()
		{
			let compose = storyboard!.instantiateViewControllerWithIdentifier("ComposeAnnouncementViewController") as! ComposeAnnouncementViewController
			compose.editingAnnouncement = APIManager.sharedManager.announcements[indexPath.row]
			presentViewController(compose, animated: true, completion: nil)
		}
		else
		{
			tableView.deselectRowAtIndexPath(indexPath, animated: true)
		}
	}
}
