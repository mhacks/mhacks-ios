//
//  ComposeAnnouncementViewController.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/23/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



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
			announceAt?.sendActions(for: .valueChanged)
			
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
					categoryCells[i].accessoryType = .checkmark
				}
				else
				{
					categoryCells[i].accessoryType = .none
				}
			}
			messageField?.resignFirstResponder()
		}
        
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ComposeAnnouncementViewController.cancel(_:)))
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ComposeAnnouncementViewController.post(_:)))
		tableView.delegate = self
		tableView.dataSource = self
		NotificationCenter.default.addObserver(self, selector: #selector(ComposeAnnouncementViewController.keyboardShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ComposeAnnouncementViewController.keyboardHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        navigationItem.title = editingAnnouncement == nil ? "New Announcement" : "Edit Announcement"
		buildCells()
	}
	
	func buildCells()
	{
		let titleCell = tableView.dequeueReusableCell(withIdentifier: "titleCell") as! TextFieldCell
		self.titleField = titleCell.textField
		cells.append(titleCell)
		
		let messageCell = tableView.dequeueReusableCell(withIdentifier: "infoCell") as! TextViewCell
		self.messageField = messageCell.textView
		cells.append(messageCell)
		
		let dateCell = tableView.dequeueReusableCell(withIdentifier: "broadcastCell") as! DatePickerCell
		dateCell.delegate = self
        dateCell.selectionStyle = UITableViewCellSelectionStyle.none
		self.announceAt = dateCell.datePicker
		cells.append(dateCell)
		
		for categoryRaw in 0...Announcement.Category.maxBit
		{
			let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryCell
			let category = Announcement.Category(rawValue: 1 << categoryRaw)
			cell.accessoryType = .none
			cell.categoryLabel.text = category.description
			cell.colorView.layer.borderColor = category.color.cgColor
			cell.colorView.layer.borderWidth = cell.colorView.frame.width
			categoryCells.append(cell)
		}
		// Set it explicitly here so that didSet gets called again
		let announce = editingAnnouncement
		editingAnnouncement = announce
		tableView.reloadData()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		announceAt.minimumDate = APIManager.shared.countdown.startDate.addingTimeInterval(-36000)
		announceAt.maximumDate = APIManager.shared.countdown.endDate.addingTimeInterval(36000)
        if editingAnnouncement == nil
		{
			let dateToSet = Date(timeIntervalSinceNow: 60 * 60)
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
			announceAt.sendActions(for: .valueChanged)
		}
	}
	
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        titleField.resignFirstResponder()
        messageField.resignFirstResponder()
    }
	func post(_: UIBarButtonItem)
	{
//		guard currentSelectedCategory != Announcement.Category.None
//		else
//		{
//			let alertController = UIAlertController(title: "Missing Category", message: "You must select at least one category", preferredStyle: UIAlertControllerStyle.alert)
//			alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
//			present(alertController, animated: true, completion: nil)
//			return
//		}
//		
//		let method = editingAnnouncement == nil ? HTTPMethod.post : .put
//		
//		let announcement = Announcement(ID: editingAnnouncement?.ID ?? "", title: titleField.text ?? editingAnnouncement?.title ?? "", message: messageField.text ?? editingAnnouncement?.message ?? "", date: announceAt?.date ?? editingAnnouncement?.date ?? Date(timeIntervalSinceNow: 0), category: currentSelectedCategory, approved: editingAnnouncement?.approved ?? false)
//		APIManager.shared.updateAnnouncement(announcement, usingMethod: method) { finished in
//			guard finished
//			else { return }
//			self.dismiss(animated: true, completion: nil)
//		}
	}
	func cancel(_: UIBarButtonItem)
	{
		DispatchQueue.main.async(execute: {
			self.dismiss(animated: true, completion: nil)
		})
	}
}

extension ComposeAnnouncementViewController : UITableViewDelegate, UITableViewDataSource
{
	func numberOfSections(in tableView: UITableView) -> Int
	{
		return 2
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return section == 0 ? cells.count : categoryCells.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		return (indexPath as NSIndexPath).section == 0 ? cells[(indexPath as NSIndexPath).row] : categoryCells[(indexPath as NSIndexPath).row]
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		guard (indexPath as NSIndexPath).section == 0, let reuse = cells[(indexPath as NSIndexPath).row].reuseIdentifier
		else
		{
			return 37.0
		}
		switch reuse
		{
			case "broadcastCell":
				return (cells[(indexPath as NSIndexPath).row] as! DatePickerCell).rowHeight
			case "infoCell":
                return 105
		default:
			return 44.0
		}
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		tableView.deselectRow(at: indexPath, animated: true)
		if (indexPath as NSIndexPath).section == 0 && cells[(indexPath as NSIndexPath).row].reuseIdentifier == "broadcastCell"
		{
			(cells[(indexPath as NSIndexPath).row] as! DatePickerCell).expanded = !(cells[(indexPath as NSIndexPath).row] as! DatePickerCell).expanded
		}
		guard (indexPath as NSIndexPath).section == 1
		else
		{
			return
		}
		let selected = Announcement.Category(rawValue: 1 << (indexPath as NSIndexPath).row)
		if currentSelectedCategory.contains(selected)
		{
			categoryCells[(indexPath as NSIndexPath).row].accessoryType = .none
			currentSelectedCategory.remove(selected)
		}
		else
		{
			currentSelectedCategory.formUnion(selected)
			categoryCells[(indexPath as NSIndexPath).row].accessoryType = .checkmark
		}
	}
}

extension ComposeAnnouncementViewController : ChangingHeightCellDelegate
{
	func cell(_ cell: UITableViewCell, didChangeSize: CGSize)
	{
		tableView.beginUpdates()
		tableView.endUpdates()
	}
	
	func keyboardShown (_ notification: Notification)
	{
		guard let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
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
		for textField in [titleField, messageField] as [UIView]
		{
			if textField.isFirstResponder
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
	
	func keyboardHidden(_ notification: Notification)
	{
		guard let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
			else {
				return
		}
		for textField in [titleField, messageField] as [UIView]
		{
			if textField.isFirstResponder
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
