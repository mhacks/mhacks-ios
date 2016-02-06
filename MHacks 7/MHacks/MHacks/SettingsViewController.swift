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
    
    let adminTool = "Announcements Pending Approval"
    var sections: [[String]] = [["Emergency","Logistics","Food","Swag",
        "Sponsor","Other"]]
	let announcementCategories = (0...Announcement.Category.maxBit).map { Announcement.Category(rawValue: 1 << $0) }
	
    var sectionNames = ["Push Notifications"]
	
	var currentPreference = Announcement.Category(rawValue: 0)
	
    override func viewDidLoad () {
        lastStatus = APIManager.sharedManager.isLoggedIn
        if APIManager.sharedManager.isLoggedIn {
            self.navigationItem.rightBarButtonItem!.title = "Logout"
        } else {
            self.navigationItem.rightBarButtonItem!.title = "Login"
        }
		guard let preference = NSUserDefaults.standardUserDefaults().objectForKey(remoteNotificationPreferencesKey) as? NSNumber
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
        if !lastStatus && APIManager.sharedManager.isLoggedIn {
         
            // TODO: add any stuff pending approval (if has privilege)
            // TODO: add any set preferences, activate appropriate cells
            
            print("I detected a login state change")
            self.navigationItem.rightBarButtonItem!.title = "Logout"
            lastStatus = true
        }
    }
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		guard let token = NSUserDefaults.standardUserDefaults().objectForKey(remoteNotificationTokenKey) as? String
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
			}
			tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
		}
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionNames.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0
		{
			return announcementCategories.count
		}
		return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0
		{
			let cell = tableView.dequeueReusableCellWithIdentifier("notificationTypes") as! CategoryCell
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
		// FIXME: Do section 2
        return UITableViewCell()
    }
	
    
    @IBAction func changeLoginStatus (sender: UIEvent) {
        if APIManager.sharedManager.isLoggedIn {
            APIManager.sharedManager.logout()
            // TODO: remove any stuff in pending approval
            // TODO: remove any set preferences, activate all cells
            print("I detected a logout state change")
            self.navigationItem.rightBarButtonItem!.title = "Login"
            lastStatus = false
        } else {
            performSegueWithIdentifier("changeLoginStatusSegue", sender: nil)
        }
    }
}
