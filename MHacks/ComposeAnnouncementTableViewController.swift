//
//  ComposeAnnouncementTableViewController.swift
//  MHacks
//
//  Created by Connor Krupp on 9/26/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class ComposeAnnouncementTableViewController: UITableViewController, UITextViewDelegate {

    // MARK: Views
    
    var titleTextField: UITextField!
    var infoTextView: UITextView!
    var datePicker: UIDatePicker!
    var sponsorSwitch: UISwitch!
    var currentCategory: IndexPath? {
        didSet {
            if let oldIndexPath = oldValue {
                tableView.cellForRow(at: oldIndexPath)?.accessoryType = .none
            }
            
            if let newIndexPath = currentCategory {
                tableView.cellForRow(at: newIndexPath)?.accessoryType = .checkmark
            }
        }
    }
    
    // MARK: Data

    var editingAnnouncement: Announcement?
    
    let sections = [
        (title: "Title", identifier: "title"),
        (title: "Info", identifier: "info"),
        (title: "Broadcast Time", identifier: "date"),
        (title: "Category", identifier: "category"),
        (title: "Flags", identifier: "sponsor")
    ]
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        self.navigationItem.title = editingAnnouncement == nil ? "New Announcement" : "Edit Announcement"
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 3:
            return Announcement.Category.maxBit - 1 // Ignore sponsored category
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: sections[indexPath.section].identifier, for: indexPath)

        cell.selectionStyle = .none
        
        switch cell {
        case let cell as SinglelineInputTableViewCell:
            self.titleTextField = cell.inputTextField
            cell.inputTextField.text = editingAnnouncement?.title
            
        case let cell as MultilineInputTableViewCell:
            cell.inputTextView.delegate = self
            self.infoTextView = cell.inputTextView
            cell.inputTextView.text = editingAnnouncement?.message
            
        case let cell as DatePickerCell:
            self.datePicker = cell.datePicker
            
            cell.datePicker.minimumDate = APIManager.shared.countdown.startDate.addingTimeInterval(-36000)
            cell.datePicker.maximumDate = APIManager.shared.countdown.endDate.addingTimeInterval(36000)
            
            cell.datePicker.date = editingAnnouncement?.date ?? Date()
            cell.datePicker.sendActions(for: .valueChanged)
            
        case let cell as CategoryCell:
            let category = Announcement.Category(rawValue: 1 << indexPath.row)
            if editingAnnouncement?.category.contains(category) ?? false {
                currentCategory = indexPath
            }
            
            cell.accessoryType = currentCategory == indexPath ? .checkmark : .none
            cell.colorView.backgroundColor = category.color
            cell.categoryLabel.text = category.description
            
        case let cell as SwitchTableViewCell:
            cell.toggle.isOn = editingAnnouncement?.isSponsored ?? false
            self.sponsorSwitch = cell.toggle
            
        default:
            fatalError("Invalid section")
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if let datePickerCell = cell as? DatePickerCell  {
            tableView.beginUpdates()
            datePickerCell.expanded = !datePickerCell.expanded
            tableView.endUpdates()
        } else if let _ = cell as? CategoryCell {
            currentCategory = indexPath
        } else if let inputCell = cell as? SinglelineInputTableViewCell {
            inputCell.becomeFirstResponder()
        } else if let inputCell = cell as? MultilineInputTableViewCell {
            inputCell.becomeFirstResponder()
        }
    }

    // MARK: UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        let currentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(currentOffset, animated: true)
    }
    
    // MARK: Actions
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        if let title = titleTextField.text, let info = infoTextView.text {
            var categoryRawValue = 0

            if let categoryIndexPath = currentCategory {
                categoryRawValue = 1 << categoryIndexPath.row
            }
            
            if sponsorSwitch.isOn {
                categoryRawValue += Announcement.Category.Sponsor.rawValue
            }
            
            let announcement = Announcement(ID: editingAnnouncement?.ID ?? "", title: title, message: info, date: datePicker.date, category: Announcement.Category(rawValue: categoryRawValue), approved: editingAnnouncement?.approved ?? false)

            APIManager.shared.updateAnnouncement(announcement, usingMethod: editingAnnouncement == nil ? .post : .put) { finished in
                guard finished else { return }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
