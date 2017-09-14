//
//  ComposeAnnouncementTableViewController.swift
//  MHacks
//
//  Created by Connor Krupp on 9/26/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class ComposeAnnouncementTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {

    // MARK: Views
    
    let titleCell = SinglelineInputTableViewCell(style: .default, reuseIdentifier: nil)
    let infoCell = MultilineInputTableViewCell(style: .default, reuseIdentifier: nil)
    let dateCell = DatePickerCell(style: .default, reuseIdentifier: nil)
    var categoryCells = [CategoryPickerCell]()
    let sponsorCell = UITableViewCell()
    
    let categories = Announcement.Category.all.flatMap {
        return $0.contains(Announcement.Category.sponsor) ? nil : $0
    }
    
    var currentCategory: Announcement.Category? {
        didSet {
            if let oldCategory = oldValue {
                let oldIndexPath = IndexPath(row: categories.index(of: oldCategory)!, section: Section.category.rawValue)
                tableView.cellForRow(at: oldIndexPath)?.accessoryType = .none
            }
            
            if oldValue == currentCategory {
                currentCategory = nil
                return
            }
            
            if let newCategory = currentCategory {
                let newIndexPath = IndexPath(row: categories.index(of: newCategory)!, section: Section.category.rawValue)
                tableView.cellForRow(at: newIndexPath)?.accessoryType = .checkmark
            }
        }
    }
    
    // MARK: Data

    var editingAnnouncement: Announcement?
    
    enum Section: Int {
        case title = 0
        case info = 1
        case broadcast = 2
        case category = 3
        case flags = 4
 
        var description: String {
            switch self {
            case .title:
                return "Title"
            case .info:
                return "Info"
            case .broadcast:
                return "Broadcast Time"
            case .category:
                return "Category"
            case .flags:
                return "Flags"
            }
        }
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Title Cell
        titleCell.inputTextField.placeholder = "Party at Krupp's Workspace"
        titleCell.inputTextField.text = editingAnnouncement?.title
        titleCell.inputTextField.autocapitalizationType = .sentences
        titleCell.inputTextField.returnKeyType = .next
        titleCell.inputTextField.delegate = self
        titleCell.selectionStyle = .none
        
        /// Info Cell
        infoCell.inputTextView.text = editingAnnouncement?.message
        infoCell.inputTextView.autocapitalizationType = .sentences
        infoCell.inputTextView.font = UIFont.preferredFont(forTextStyle: .body)
        infoCell.inputTextView.isScrollEnabled = false
        infoCell.inputTextView.delegate = self
        infoCell.selectionStyle = .none
        
        /// Date Picker Cell
        let minDate = APIManager.shared.configuration.startDate.addingTimeInterval(-36000)
        let maxDate = APIManager.shared.configuration.endDate.addingTimeInterval(36000)
        
        dateCell.datePicker.minimumDate = minDate
        dateCell.datePicker.maximumDate = maxDate
        
        dateCell.datePicker.date = editingAnnouncement?.date ?? min(max(minDate, Date()), maxDate)
        dateCell.datePicker.sendActions(for: .valueChanged)
        
        dateCell.selectionStyle = .none
        
        /// Category Cells
        categoryCells = categories.map {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryPickerCell
            cell.categoryLabel.text = $0.descriptionDisplay
            cell.colorView.fillColor = $0.color
            if editingAnnouncement?.category.contains($0) ?? false {
                currentCategory = $0
                cell.accessoryType = .checkmark
            }
            
            return cell
        }
        
        /// Sponsor Cell
        let toggle = UISwitch()
        
        toggle.isOn = editingAnnouncement?.isSponsored ?? false
        sponsorCell.textLabel?.text = "Sponsored"
        sponsorCell.accessoryView = toggle
        sponsorCell.selectionStyle = .none
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        tableView.keyboardDismissMode = .interactive
        tableView.reloadData()
        
        self.navigationItem.title = editingAnnouncement == nil ? "New Announcement" : "Edit Announcement"
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.description
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Section(rawValue: section) == .category {
            return categoryCells.count
        }
        
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return titleCell
        case 1:
            return infoCell
        case 2:
            return dateCell
        case 3:
            return categoryCells[indexPath.row]
        case 4:
            return sponsorCell
        default:
            fatalError("Invalid Index")
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = Section(rawValue: indexPath.section)
        
        if section == .broadcast  {
            tableView.beginUpdates()
            dateCell.expanded = !dateCell.expanded
            tableView.endUpdates()
        } else if section == .category {
            currentCategory = categories[indexPath.row]
        } else if section == .title {
            titleCell.becomeFirstResponder()
        } else if section == .info {
            infoCell.becomeFirstResponder()
        }
    }

    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        infoCell.inputTextView.becomeFirstResponder()
        return false
    }
    
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
        if let title = titleCell.inputTextField.text, let info = infoCell.inputTextView.text {
            
            if title.isEmpty || info.isEmpty {
                let errorAlert = UIAlertController(title: "Missing Data", message: "You must both a title and message", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Oh.", style: .default, handler: nil))
                self.present(errorAlert, animated: true)
                return
            }
            
            var categoryRawValue = currentCategory?.rawValue ?? 0
            if (sponsorCell.accessoryView as? UISwitch)?.isOn ?? false {
                categoryRawValue += Announcement.Category.sponsor.rawValue
            }
            
            let announcement = Announcement(ID: editingAnnouncement?.ID ?? "", title: title, message: info, date: dateCell.datePicker.date, category: Announcement.Category(rawValue: categoryRawValue), approved: editingAnnouncement?.approved ?? false)

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
