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
		
		lastStatus = APIManager.shared.userState.loggedIn
		guard let preference = defaults.object(forKey: remoteNotificationPreferencesKey) as? NSNumber
		else
		{
			// We shouldn't ever reach here though...
			currentPreference = Announcement.Category(rawValue: 63)
			return
		}
		let categories = Announcement.Category(rawValue: preference.intValue)
		currentPreference = categories.contains(Announcement.Category.Emergency) ? categories : categories.intersection(Announcement.Category.Emergency)
    }
    
    override func viewDidAppear(_ animated: Bool) {
		lastStatus = APIManager.shared.userState.loggedIn
		
        if APIManager.shared.canEditAnnouncements() {
			// FIXME: No longer need this!
//            NotificationCenter.default.listenFor(.UnapprovedAnnouncementsUpdated, observer: self, selector: #selector(SettingsViewController.unapprovedAnnouncementsUpdated(_:)))
			
            APIManager.shared.updateUnapprovedAnnouncements()
        }
    }
    
    func unapprovedAnnouncementsUpdated (_ notification: Notification? = nil) {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        })
    }
    
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self)
		
//		guard let token = defaults.object(forKey: remoteNotificationTokenKey) as? String
//		else
//		{
//			return
//		}
//		if let preference = defaults.object(forKey: remoteNotificationPreferencesKey) as? NSNumber
//		{
//			guard currentPreference != Announcement.Category(rawValue: preference.intValue)
//			else
//			{
//				// There was no change in preference return
//				return
//			}
//		}
		// TODO: Use new update APNS token API
//		APIManager.shared.updateAPNSToken(token, preference: currentPreference.rawValue, method: .put, completion: {
//			updated in
//			guard updated else { return }
//			guard self.currentPreference.rawValue != (defaults.object(forKey: remoteNotificationPreferencesKey) as? NSNumber)?.intValue
//			else
//			{
//				return
//			}
//			defaults.set(self.currentPreference.rawValue, forKey: remoteNotificationPreferencesKey)
//		})
	}
	
	// MARK: - Table View Data Source
	
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (APIManager.shared.canEditAnnouncements()) {
            return settingTypes.count
        }
        return 1
    }
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return announcementCategories.count
		}
		return APIManager.shared.unapprovedAnnouncements.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if (indexPath as NSIndexPath).section == 0
		{
			let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell") as! CategoryCell
			let category = announcementCategories[(indexPath as NSIndexPath).row]
			cell.categoryLabel.text = category.description
			cell.colorView.layer.borderColor = category.color.cgColor
			cell.colorView.layer.borderWidth = cell.colorView.frame.width
			if currentPreference.contains(category)
			{
				cell.accessoryType = .checkmark
			}
			else
			{
				cell.accessoryType = .none
			}
			return cell
		}
		
		let announcement = APIManager.shared.unapprovedAnnouncements[(indexPath as NSIndexPath).row]
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "announcementCell") as! AnnouncementCell
		cell.titleLabel.text = announcement.title
		cell.dateLabel.text = announcement.localizedDate
		cell.messageLabel.text = announcement.message
		cell.colorView.layer.borderColor = announcement.category.color.cgColor
		cell.colorView.layer.borderWidth = cell.colorView.frame.width
		return cell
	}
	
	// MARK: - Table View Delegate
	
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingTypes[section]
    }
	
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath as NSIndexPath).section != 0
    }
	
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "✕") { action, index in
            let confirm = UIAlertController(title: "Announcement Deletion", message: "This announcement will be deleted from the approval list for all MHacks organizers.",preferredStyle: .alert)
            confirm.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            confirm.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {(action: UIAlertAction!) in
                
                APIManager.shared.deleteUnapprovedAnnouncement((indexPath as NSIndexPath).row, completion: {deleted in
                    if deleted {
                        self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    }
                })
            }))
            self.present(confirm, animated: true, completion: nil)
        }
        delete.backgroundColor = UIColor.red
        
        let approve = UITableViewRowAction(style: .normal, title: "✓") { action, index in
            let confirm = UIAlertController(title: "Announcement Approval", message: "This announcement will be pushed to all MHacks participants, sponsors, and organizers.",preferredStyle: .alert)
            confirm.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            confirm.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {(action: UIAlertAction!) in
                
                APIManager.shared.approveAnnouncement((indexPath as NSIndexPath).row, completion: {approved in
                    if approved {
                        self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    }
                })
            }))
            self.present(confirm, animated: true, completion: nil)
        }
        approve.backgroundColor = UIColor.blue
        
        return [delete, approve]
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if (indexPath as NSIndexPath).section == 0
		{
			let category = announcementCategories[(indexPath as NSIndexPath).row]
			guard !category.contains(Announcement.Category.Emergency)
				else
			{
				let alertController = UIAlertController(title: "Denied", message: "Emergency notifications must stay active during the entire hackathon.", preferredStyle: .alert)
				alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
				present(alertController, animated: true, completion: nil)
				return
			}
			if currentPreference.remove(category) == nil
			{
				currentPreference.insert(category)
				tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
			}
			else
			{
				tableView.cellForRow(at: indexPath)?.accessoryType = .none
			}
		}
		else
		{
			guard APIManager.shared.canEditAnnouncements()
				else
			{
				lastStatus = APIManager.shared.userState.loggedIn
				return
			}
			let compose = storyboard!.instantiateViewController(withIdentifier: "ComposeAnnouncementViewController") as! UINavigationController
			(compose.topViewController as? ComposeAnnouncementViewController)?.editingAnnouncement = APIManager.shared.announcements[(indexPath as NSIndexPath).row]
			present(compose, animated: true, completion: nil)
		}
	}
	
    @IBAction func changeLoginStatus(_ sender: UIBarButtonItem) {
        if APIManager.shared.userState.loggedIn {
            APIManager.shared.logout()
			lastStatus = APIManager.shared.userState.loggedIn
        } else {
            performSegue(withIdentifier: "changeLoginStatusSegue", sender: nil)
        }
    }
}
