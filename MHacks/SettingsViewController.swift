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
    
    var settingTypes = ["Push Notifications","Announcements Pending Approval"]
    
	let announcementCategories = (0...Announcement.Category.maxBit).map { Announcement.Category(rawValue: 1 << $0) }
	var currentPreference = Announcement.Category(rawValue: 0)
	
    override func viewDidLoad () {
        lastStatus = APIManager.sharedManager.isLoggedIn
        if APIManager.sharedManager.isLoggedIn {
            self.navigationItem.rightBarButtonItem!.title = "Logout"
        } else {
            self.navigationItem.rightBarButtonItem!.title = "Login"
        }
		guard let preference = defaults.objectForKey(remoteNotificationPreferencesKey) as? NSNumber
		else
		{
			// We shouldn't ever reach here though...
			currentPreference = Announcement.Category(rawValue: 63)
			return
		}
		let categories = Announcement.Category(rawValue: preference.integerValue)
		currentPreference = categories.contains(Announcement.Category.Emergency) ? categories : categories.intersect(Announcement.Category.Emergency)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100.0
    }
    
    override func viewDidAppear(animated: Bool) {
        if !lastStatus && APIManager.sharedManager.isLoggedIn {
            self.tableView.reloadData()
            self.navigationItem.rightBarButtonItem!.title = "Logout"
            lastStatus = true
        }
        
        if APIManager.sharedManager.canEditAnnouncements() {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "unapprovedAnnouncementsUpdated:", name: APIManager.unapprovedAnnouncementsUpdatedNotification, object: nil)
            
            APIManager.sharedManager.updateUnapprovedAnnouncements()
        }
    }
    
    func unapprovedAnnouncementsUpdated (notification: NSNotification? = nil) {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		guard let token = defaults.objectForKey(remoteNotificationTokenKey) as? String
		else
		{
			return
		}
		APIManager.sharedManager.updateAPNSToken(token, preference: currentPreference.rawValue, method: .PUT, completion: { updated in
			if !updated
			{
				NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: nil)
			}
		})
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
        
        // add selection pushing to edit
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (APIManager.sharedManager.canEditAnnouncements()) {
            return settingTypes.count
        }
        
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return settingTypes[section]
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
        
        return [delete,approve]
    }
    
    @IBAction func changeLoginStatus (sender: UIEvent) {
        if APIManager.sharedManager.isLoggedIn {
            APIManager.sharedManager.logout()
            self.tableView.reloadData()
            self.navigationItem.rightBarButtonItem!.title = "Login"
            lastStatus = false
        } else {
            performSegueWithIdentifier("changeLoginStatusSegue", sender: nil)
        }
    }
}
