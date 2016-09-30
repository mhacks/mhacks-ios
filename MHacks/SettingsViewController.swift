//
//  SettingsViewController.swift
//  MHacks
//
//  Created by Ameya Khare on 2/5/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
	let announcementCategories = (0...Announcement.Category.maxBit).map { Announcement.Category(rawValue: 1 << $0) }
	var currentPreference = Announcement.Category(rawValue: 0)
	
    override func viewDidLoad () {
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 100.0
		
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
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		APIManager.shared.updateAPNSToken(preference: currentPreference.rawValue)
	}
	
	// MARK: - Table View Data Source
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return announcementCategories.count
		}
		return 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard indexPath.section == 0
		else {
			fatalError("Did not update code properly")
		}
		let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell") as! CategoryCell
		let category = announcementCategories[(indexPath as NSIndexPath).row]
		cell.categoryLabel.text = category.description
		cell.colorView.fillColor = category.color
		
		let switchView = cell.accessoryView as! UISwitch
		switchView.setOn(currentPreference.contains(category), animated: false)
		switchView.addTarget(self, action: #selector(self.switchToggled(sender:)), for: UIControlEvents.valueChanged)
		switchView.tag = indexPath.row
		if category.contains(Announcement.Category.Emergency) {
			// Disable Emergency CategoryCell UISwitch
			switchView.isEnabled = false
		}
		
		return cell
	}
	
	func switchToggled(sender: UISwitch) {
		let category = announcementCategories[sender.tag]
		
		if sender.isOn {
			currentPreference.insert(category)
		} else {
			currentPreference.remove(category)
		}
	}
	
	@IBAction func doneButtonPressed(_: UIBarButtonItem)
	{
		dismiss(animated: true, completion: nil)
	}
}
