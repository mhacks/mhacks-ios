//
//  SettingsViewController.swift
//  MHacks
//
//  Created by Ameya Khare on 2/5/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
	
    var settingTypes = ["Push Notifications"]
    
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
	
    override func numberOfSections(in tableView: UITableView) -> Int {
        return settingTypes.count
    }
	
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
	
	// MARK: - Table View Delegate
	
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingTypes[section]
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard indexPath.section == 0
			else { fatalError("Did not update code properly") }
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
	
	@IBAction func doneButtonPressed(_: UIBarButtonItem)
	{
		dismiss(animated: true, completion: nil)
	}
}
