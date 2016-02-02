//
//  ComposeAnnouncementViewController.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/23/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import UIKit


class ComposeAnnouncementViewController: UIViewController {
	weak var titleField: UITextField!
	weak var messageField: UITextField!
	weak var announceAt: UIDatePicker!
	var currentSelectedCategory = Announcement.Category.None
	@IBOutlet var tableView: UITableView!
	
	var cells = [UITableViewCell]()
	var categoryCells = [UITableViewCell]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "post:")
		tableView.delegate = self
		tableView.dataSource = self
		buildCells()
	}
	
	func buildCells()
	{
		let titleCell = tableView.dequeueReusableCellWithIdentifier("titleCell") as! TextFieldCell
		self.titleField = titleCell.textField
		cells.append(titleCell)
		
		let messageCell = tableView.dequeueReusableCellWithIdentifier("infoCell") as! TextFieldCell
		self.messageField = messageCell.textField
		cells.append(messageCell)
		
		let dateCell = tableView.dequeueReusableCellWithIdentifier("broadcastCell") as! DatePickerCell
		self.announceAt = dateCell.datePicker
		cells.append(dateCell)
		
		for categoryRaw in 0...Announcement.Category.maxBit
		{
			let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "categoryCell")
			cell.textLabel?.text = Announcement.Category(rawValue: 1 << categoryRaw).description
			cell.accessoryType = .None
			categoryCells.append(cell)
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		announceAt.minimumDate = NSDate(timeIntervalSinceNow: 0)
		announceAt.maximumDate = APIManager.sharedManager.countdown.endDate
	}
	
	@IBAction func post(_: UIBarButtonItem)
	{
		let announcement = Announcement(ID: "", title: titleField.text ?? "", message: messageField.text ?? "", date: announceAt.date, category: currentSelectedCategory, owner: "", approved: false)
		
		APIManager.sharedManager.postAnnouncement(announcement, completion: { finished in
			guard finished
			else
			{
				return
			}
			self.navigationController?.popViewControllerAnimated(true)
		})
	}
}
extension ComposeAnnouncementViewController : UITableViewDelegate, UITableViewDataSource
{
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 2
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return section == 0 ? cells.count : categoryCells.count
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		return indexPath.section == 0 ? cells[indexPath.row] : categoryCells[indexPath.row]
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	{
		guard indexPath.section == 0, let reuse = cells[indexPath.row].reuseIdentifier
		else
		{
			return 44.0
		}
		switch reuse
		{
			case "titleCell":
				return 76.5
			case "broadcastCell":
				return 232.5
			case "infoCell":
				return 46.5
		default:
			return 44.0
		}
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		guard indexPath.section == 1
		else
		{
			return
		}
		let selected = Announcement.Category(rawValue: 1 << indexPath.row)
		if currentSelectedCategory.contains(selected)
		{
			categoryCells[indexPath.row].accessoryType = .None
			currentSelectedCategory.remove(selected)
		}
		else
		{
			currentSelectedCategory.unionInPlace(selected)
			categoryCells[indexPath.row].accessoryType = .Checkmark
		}
	}
}