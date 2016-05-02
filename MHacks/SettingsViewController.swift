//
//  SettingsViewController.swift
//  MHacks
//
//  Created by Ameya Khare on 2/5/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    var lastStatus: Bool = false
	{
		didSet
		{
			if lastStatus {
				self.navigationItem.rightBarButtonItem!.title = "Logout"
			} else {
				self.navigationItem.rightBarButtonItem!.title = "Login"
			}
			tableView.reloadData()
		}
	}
	
    var settingTypes = ["Push Notifications","Announcements Pending Approval"]
    
	let announcementCategories = (0...Announcement.Category.maxBit).map { Announcement.Category(rawValue: 1 << $0) }
	var currentPreference = Announcement.Category(rawValue: 0)
	
    override func viewDidLoad () {
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 100.0
		
		lastStatus = APIManager.sharedManager.isLoggedIn
		guard let preference = defaults.objectForKey(remoteNotificationPreferencesKey) as? NSNumber
		else
		{
			// We shouldn't ever reach here though...
			currentPreference = Announcement.Category(rawValue: 63)
			return
		}
		let categories = Announcement.Category(rawValue: preference.integerValue)
		currentPreference = categories.contains(Announcement.Category.Emergency) ? categories : categories.intersect(Announcement.Category.Emergency)
    }
    
    override func viewDidAppear(animated: Bool) {
		lastStatus = APIManager.sharedManager.isLoggedIn
		
        if APIManager.sharedManager.canEditAnnouncements() {
            NSNotificationCenter.defaultCenter().listenFor(.UnapprovedAnnouncementsUpdated, observer: self, selector: #selector(SettingsViewController.unapprovedAnnouncementsUpdated(_:)))
            
            APIManager.sharedManager.updateUnapprovedAnnouncements()
        }
    }
    
    func unapprovedAnnouncementsUpdated (notification: NSNotification? = nil) {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
        })
    }
    
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
		
		guard let token = defaults.objectForKey(remoteNotificationTokenKey) as? String
		else
		{
			return
		}
		if let preference = defaults.objectForKey(remoteNotificationPreferencesKey) as? NSNumber
		{
			guard currentPreference != Announcement.Category(rawValue: preference.integerValue)
			else
			{
				// There was no change in preference return
				return
			}
		}
		APIManager.sharedManager.updateAPNSToken(token, preference: currentPreference.rawValue, method: .PUT, completion: {
			updated in
			guard updated else { return }
			guard self.currentPreference.rawValue != (defaults.objectForKey(remoteNotificationPreferencesKey) as? NSNumber)?.integerValue
			else
			{
				return
			}
			defaults.setInteger(self.currentPreference.rawValue, forKey: remoteNotificationPreferencesKey)
		})
	}
	
	// MARK: - Table View Data Source
	
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (APIManager.sharedManager.canEditAnnouncements()) {
            return settingTypes.count
        }
        return 1
    }
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return announcementCategories.count
		}
		return APIManager.sharedManager.unapprovedAnnouncements.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0
		{
			let cell = tableView.dequeueReusableCellWithIdentifier("notificationCell") as! CategoryCell
			let category = announcementCategories[indexPath.row]
			cell.categoryLabel.text = category.description
			cell.colorView.layer.borderColor = category.color.CGColor
			cell.colorView.layer.borderWidth = cell.colorView.frame.width
			if currentPreference.contains(category)
			{
				cell.accessoryType = .Checkmark
			}
			else
			{
				cell.accessoryType = .None
			}
			return cell
		}
		
		let announcement = APIManager.sharedManager.unapprovedAnnouncements[indexPath.row]
		
		let cell = tableView.dequeueReusableCellWithIdentifier("announcementCell") as! AnnouncementCell
		cell.titleLabel.text = announcement.title
		cell.dateLabel.text = announcement.localizedDate
		cell.dateLabel.font = Announcement.dateFont
		cell.messageLabel.text = announcement.message
		cell.colorView.layer.borderColor = announcement.category.color.CGColor
		cell.colorView.layer.borderWidth = cell.colorView.frame.width
		return cell
	}
	
	// MARK: - Table View Delegate
	
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingTypes[section]
    }
	
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section != 0
    }
	
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .Normal, title: "✕") { action, index in
            let confirm = UIAlertController(title: "Announcement Deletion", message: "This announcement will be deleted from the approval list for all MHacks organizers.",preferredStyle: .Alert)
            confirm.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            confirm.addAction(UIAlertAction(title: "Confirm", style: .Default, handler: {(action: UIAlertAction!) in
                
                APIManager.sharedManager.deleteUnapprovedAnnouncement(indexPath.row, completion: {deleted in
                    if deleted {
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                    }
                })
            }))
            self.presentViewController(confirm, animated: true, completion: nil)
        }
        delete.backgroundColor = UIColor.redColor()
        
        let approve = UITableViewRowAction(style: .Normal, title: "✓") { action, index in
            let confirm = UIAlertController(title: "Announcement Approval", message: "This announcement will be pushed to all MHacks participants, sponsors, and organizers.",preferredStyle: .Alert)
            confirm.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            confirm.addAction(UIAlertAction(title: "Confirm", style: .Default, handler: {(action: UIAlertAction!) in
                
                APIManager.sharedManager.approveAnnouncement(indexPath.row, completion: {approved in
                    if approved {
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                    }
                })
            }))
            self.presentViewController(confirm, animated: true, completion: nil)
        }
        approve.backgroundColor = UIColor.blueColor()
        
        return [delete, approve]
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		if indexPath.section == 0
		{
			let category = announcementCategories[indexPath.row]
			guard !category.contains(Announcement.Category.Emergency)
				else
			{
				let alertController = UIAlertController(title: "Denied", message: "Emergency notifications must stay active during the entire hackathon.", preferredStyle: .Alert)
				alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
				presentViewController(alertController, animated: true, completion: nil)
				return
			}
			if currentPreference.remove(category) == nil
			{
				currentPreference.insert(category)
				tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
			}
			else
			{
				tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
			}
		}
		else
		{
			guard APIManager.sharedManager.canEditAnnouncements()
				else
			{
				lastStatus = APIManager.sharedManager.isLoggedIn
				return
			}
			let compose = storyboard!.instantiateViewControllerWithIdentifier("ComposeAnnouncementViewController") as! UINavigationController
			(compose.topViewController as? ComposeAnnouncementViewController)?.editingAnnouncement = APIManager.sharedManager.announcements[indexPath.row]
			presentViewController(compose, animated: true, completion: nil)
		}
	}
	
    @IBAction func changeLoginStatus(sender: UIBarButtonItem) {
        if APIManager.sharedManager.isLoggedIn {
            APIManager.sharedManager.logout()
			lastStatus = APIManager.sharedManager.isLoggedIn
        } else {
            performSegueWithIdentifier("changeLoginStatusSegue", sender: nil)
        }
    }
}
