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
    
    // TODO: CHANGE FROM HARDCODED PENGING APPROVAL TO APIMANAGER DATA
    var pendingApproval:[Announcement] = [Announcement(ID: "2", title: "h0w 2 spell", message: "dickshunayyrees?", date: NSDate(timeIntervalSince1970: NSTimeInterval(35655333)), category: Announcement.Category.Sponsor, owner: "apl", approved: false),
    Announcement(ID: "3", title: "Perfect Grammar", message: "There is an idiot above me and I'm intentionally making this announcement message very long so that it takes up multiple lines.", date: NSDate(timeIntervalSince1970: NSTimeInterval(356554)), category: Announcement.Category.Swag, owner: "MHacks: Refactor", approved: false)]
    // END TODO
    
	let announcementCategories = (0...Announcement.Category.maxBit).map { Announcement.Category(rawValue: 1 << $0) }
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
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100.0
    }
    
    override func viewDidAppear(animated: Bool) {
        if !lastStatus && APIManager.sharedManager.isLoggedIn {
            // FUNCTIONALLY THE USER HAS LOGGED IN
            
            print("I detected a login state change")
            self.tableView.reloadData()
            self.navigationItem.rightBarButtonItem!.title = "Logout"
            lastStatus = true
        }
        
        tableView.reloadData()
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
        
        // TODO: CHANGE FROM HARDCODED PENGING APPROVAL TO APIMANAGER DATA
        guard pendingApproval.count > 0 else {
            return 1
        }
        
        return pendingApproval.count
        // END TODO
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
        
        guard pendingApproval.count > 0 else {
            let cell = UITableViewCell()
            cell.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.textLabel?.textColor = UIColor.grayColor()
            cell.textLabel?.text = "NO PENDING ANNOUNCEMENTS"
            cell.textLabel?.font = UIFont.systemFontOfSize(12)
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("announcementCell") as! AnnouncementCell
        cell.titleLabel.text = pendingApproval[indexPath.row].title
        cell.dateLabel.text = pendingApproval[indexPath.row].localizedDate
        cell.dateLabel.font = Announcement.dateFont
        cell.messageLabel.text = pendingApproval[indexPath.row].message
        cell.colorView.layer.borderColor = pendingApproval[indexPath.row].category.color.CGColor
        cell.colorView.layer.borderWidth = cell.colorView.frame.width
        return cell
    }
	
    
    @IBAction func changeLoginStatus (sender: UIEvent) {
        if APIManager.sharedManager.isLoggedIn {
            APIManager.sharedManager.logout()
            // TODO: remove any stuff in pending approval
            print("I detected a logout state change")
            self.tableView.reloadData()
            self.navigationItem.rightBarButtonItem!.title = "Login"
            lastStatus = false
        } else {
            performSegueWithIdentifier("changeLoginStatusSegue", sender: nil)
        }
    }
}
