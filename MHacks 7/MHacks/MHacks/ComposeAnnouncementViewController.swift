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
	weak var messageField: UITextView!
	weak var announceAt: UIDatePicker!
	var currentSelectedCategory = Announcement.Category.None
	@IBOutlet var tableView: UITableView!
	
	var cells = [UITableViewCell]()
	var categoryCells = [UITableViewCell]()
	
	
	var editingAnnouncement: Announcement?
	{
		didSet {
			guard let announce = editingAnnouncement
			else
			{
				return
			}
			titleField?.text = announce.title
			messageField?.text = announce.message
			messageField?.delegate?.textViewDidChange?(messageField!)
			announceAt?.date = announce.date
			currentSelectedCategory = announce.category
			guard !categoryCells.isEmpty
			else
			{
				return
			}
			for i in 0...Announcement.Category.maxBit
			{
				if currentSelectedCategory.contains(Announcement.Category(rawValue: 1 << i))
				{
					categoryCells[i].accessoryType = .Checkmark
				}
				else
				{
					categoryCells[i].accessoryType = .None
				}
			}
		}
	}
	
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
		
		let messageCell = tableView.dequeueReusableCellWithIdentifier("infoCell") as! TextViewCell
		messageCell.delegate = self
		self.messageField = messageCell.textView
		cells.append(messageCell)
		
		let dateCell = tableView.dequeueReusableCellWithIdentifier("broadcastCell") as! DatePickerCell
		self.announceAt = dateCell.datePicker
		cells.append(dateCell)
		
		for categoryRaw in 0...Announcement.Category.maxBit
		{
			let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "categoryCell")
			let category = Announcement.Category(rawValue: 1 << categoryRaw)
			cell.textLabel?.text = category.description
			categoryCells.append(cell)
		}
		// Set it explicitly here so that didSet gets called again
		let announce = editingAnnouncement
		editingAnnouncement = announce
		tableView.reloadData()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		announceAt.minimumDate = APIManager.sharedManager.countdown.startDate
		announceAt.maximumDate = APIManager.sharedManager.countdown.endDate
	}
	
	func pushEditAnnouncement()
	{
		let editedAnnouncement = Announcement(ID: editingAnnouncement!.ID, title: titleField.text ?? editingAnnouncement!.title, message: messageField.text ?? editingAnnouncement!.message, date: announceAt.date, category: currentSelectedCategory, owner: editingAnnouncement!.owner, approved: editingAnnouncement!.approved)
		APIManager.sharedManager.updateAnnouncement(editedAnnouncement, usingMethod: .PATCH) { finished in
			guard finished
			else { return }
			self.navigationController?.popViewControllerAnimated(true)
		}
	}
	
	@IBAction func post(_: UIBarButtonItem)
	{
		let method = editingAnnouncement == nil ? HTTPMethod.POST : .PATCH
		
		let announcement = Announcement(ID: editingAnnouncement?.ID ?? "", title: titleField.text ?? editingAnnouncement?.title ?? "", message: messageField.text ?? editingAnnouncement?.message ?? "", date: announceAt?.date ?? editingAnnouncement?.date ?? NSDate(timeIntervalSinceNow: 0), category: currentSelectedCategory, owner: editingAnnouncement?.owner ?? "", approved: editingAnnouncement?.approved ?? false)
		APIManager.sharedManager.updateAnnouncement(announcement, usingMethod: method) { finished in
			guard finished
			else { return }
			self.navigationController?.popViewControllerAnimated(true)
		}
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
				return (cells[indexPath.row] as! TextViewCell).rowHeight
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

extension ComposeAnnouncementViewController : TextViewCellDelegate
{
	func cell(cell: TextViewCell, didChangeSize: CGSize)
	{
		tableView.beginUpdates()
		tableView.endUpdates()
	}
}