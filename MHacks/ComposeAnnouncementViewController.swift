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
			announceAt?.setDate(announce.date, animated: true)
			announceAt?.sendActionsForControlEvents(.ValueChanged)
			
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
			messageField?.resignFirstResponder()
		}
        
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(ComposeAnnouncementViewController.cancel(_:)))
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(ComposeAnnouncementViewController.post(_:)))
		tableView.delegate = self
		tableView.dataSource = self
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ComposeAnnouncementViewController.keyboardShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ComposeAnnouncementViewController.keyboardHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
        navigationItem.title = editingAnnouncement == nil ? "New Announcement" : "Edit Announcement"
		buildCells()
	}
	
	func buildCells()
	{
		let titleCell = tableView.dequeueReusableCellWithIdentifier("titleCell") as! TextFieldCell
		self.titleField = titleCell.textField
		cells.append(titleCell)
		
		let messageCell = tableView.dequeueReusableCellWithIdentifier("infoCell") as! TextViewCell
		self.messageField = messageCell.textView
		cells.append(messageCell)
		
		let dateCell = tableView.dequeueReusableCellWithIdentifier("broadcastCell") as! DatePickerCell
		dateCell.delegate = self
        dateCell.selectionStyle = UITableViewCellSelectionStyle.None
		self.announceAt = dateCell.datePicker
		cells.append(dateCell)
		
		for categoryRaw in 0...Announcement.Category.maxBit
		{
			let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell") as! CategoryCell
			let category = Announcement.Category(rawValue: 1 << categoryRaw)
			cell.accessoryType = .None
			cell.categoryLabel.text = category.description
			cell.colorView.layer.borderColor = category.color.CGColor
			cell.colorView.layer.borderWidth = cell.colorView.frame.width
			categoryCells.append(cell)
		}
		// Set it explicitly here so that didSet gets called again
		let announce = editingAnnouncement
		editingAnnouncement = announce
		tableView.reloadData()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		announceAt.minimumDate = APIManager.sharedManager.countdown.startDate.dateByAddingTimeInterval(-36000)
		announceAt.maximumDate = APIManager.sharedManager.countdown.endDate.dateByAddingTimeInterval(36000)
        if editingAnnouncement == nil
		{
			let dateToSet = NSDate(timeIntervalSinceNow: 60 * 60)
			if (dateToSet > announceAt.maximumDate)
			{
				announceAt.setDate(announceAt.maximumDate!, animated: true)
			}
			else if (dateToSet < announceAt.minimumDate)
			{
				announceAt.setDate(announceAt.minimumDate!, animated: true)
			}
			else
			{
				announceAt.setDate(dateToSet, animated: true)
			}
			announceAt.sendActionsForControlEvents(.ValueChanged)
		}
	}
	
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        titleField.resignFirstResponder()
        messageField.resignFirstResponder()
    }
	func post(_: UIBarButtonItem)
	{
		guard currentSelectedCategory != Announcement.Category.None
		else
		{
			let alertController = UIAlertController(title: "Missing Category", message: "You must select at least one category", preferredStyle: UIAlertControllerStyle.Alert)
			alertController.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
			presentViewController(alertController, animated: true, completion: nil)
			return
		}
		
		let method = editingAnnouncement == nil ? HTTPMethod.POST : .PUT
		
		let announcement = Announcement(ID: editingAnnouncement?.ID ?? "", title: titleField.text ?? editingAnnouncement?.title ?? "", message: messageField.text ?? editingAnnouncement?.message ?? "", date: announceAt?.date ?? editingAnnouncement?.date ?? NSDate(timeIntervalSinceNow: 0), category: currentSelectedCategory, owner: editingAnnouncement?.owner ?? "", approved: editingAnnouncement?.approved ?? false)
		APIManager.sharedManager.updateAnnouncement(announcement, usingMethod: method) { finished in
			guard finished
			else { return }
			self.dismissViewControllerAnimated(true, completion: nil)
		}
	}
	func cancel(_: UIBarButtonItem)
	{
		dispatch_async(dispatch_get_main_queue(), {
			self.dismissViewControllerAnimated(true, completion: nil)
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
			return 37.0
		}
		switch reuse
		{
			case "broadcastCell":
				return (cells[indexPath.row] as! DatePickerCell).rowHeight
			case "infoCell":
                return 105
		default:
			return 44.0
		}
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		if indexPath.section == 0 && cells[indexPath.row].reuseIdentifier == "broadcastCell"
		{
			(cells[indexPath.row] as! DatePickerCell).expanded = !(cells[indexPath.row] as! DatePickerCell).expanded
		}
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

extension ComposeAnnouncementViewController : ChangingHeightCellDelegate
{
	func cell(cell: UITableViewCell, didChangeSize: CGSize)
	{
		tableView.beginUpdates()
		tableView.endUpdates()
	}
	
	func keyboardShown (notification: NSNotification)
	{
		guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
		else {
			return
		}
		var contentInsets = tableView.contentInset
		contentInsets.bottom += keyboardSize.height
		tableView.contentInset = contentInsets
		tableView.scrollIndicatorInsets = contentInsets
		var rect = self.view.frame
		rect.size.height -= keyboardSize.height
		var activeField : UIView?
		for textField in [titleField, messageField]
		{
			if textField.isFirstResponder()
			{
				activeField = textField
				break
			}
		}
		guard let active = activeField
		else
		{
			return
		}
		if (!rect.contains(active.frame.origin))
		{
			tableView.scrollRectToVisible(active.frame, animated: true)
		}
	}
	
	func keyboardHidden(notification: NSNotification)
	{
		guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
			else {
				return
		}
		for textField in [titleField, messageField]
		{
			if textField.isFirstResponder()
			{
				textField.resignFirstResponder()
				break
			}
		}
		var contentInsets = tableView.contentInset
		contentInsets.bottom -= keyboardSize.height
		tableView.contentInset = contentInsets
		tableView.scrollIndicatorInsets = contentInsets
	}
}