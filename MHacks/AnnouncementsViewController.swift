//
//  AnnouncementsViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 11/18/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class AnnouncementsViewController: UITableViewController {
	
    // MARK: Model
	
	fileprivate func fetch() {
		refreshControl?.beginRefreshing()
		APIManager.shared.updateAnnouncements { _ in
			DispatchQueue.main.async(execute: {
				self.refreshControl?.endRefreshing()
			})
		}
	}
	
    // MARK: ViewController Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
		refreshControl!.addTarget(self, action: #selector(AnnouncementsViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 100.0
		
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if APIManager.shared.canPostAnnouncements() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(AnnouncementsViewController.compose(_:)))
        }
        else {
            navigationItem.rightBarButtonItem = nil
        }
		NotificationCenter.default.addObserver(self, selector: #selector(AnnouncementsViewController.announcementsUpdated(_:)), name: APIManager.AnnouncementsUpdatedNotification, object: nil)
		
		if APIManager.shared.canEditAnnouncements() {
			tableView.allowsSelection = true
			tableView.allowsMultipleSelection = false
		}
		else {
			tableView.allowsSelection = false
			tableView.allowsMultipleSelection = false
		}
		if let indexPath = tableView.indexPathForSelectedRow
		{
			transitionCoordinator?.animate(alongsideTransition: { context in
				self.tableView.deselectRow(at: indexPath, animated: animated)
				}, completion: { context in
					if context.isCancelled {
						self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
					}
			})
		}
		tableView.reloadData()
		fetch()
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Actions/Notifications
	func refresh(_ sender: UIRefreshControl) {
		fetch()
	}
	func announcementsUpdated(_ notification: Notification? = nil) {
		DispatchQueue.main.async(execute: {
			CATransaction.begin()
			self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
			CATransaction.commit()
		})
	}
	
	func compose(_ sender: UIBarButtonItem) {
		guard APIManager.shared.canPostAnnouncements()
		else {
			navigationItem.rightBarButtonItem = nil
			return
		}
		let compose = storyboard!.instantiateViewController(withIdentifier: "ComposeAnnouncementViewController") as! UINavigationController
		present(compose, animated: true, completion: nil)
	}
	
    // MARK: Table View Data
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return APIManager.shared.announcements.count
    }
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath) as! AnnouncementCell

        let announcement = APIManager.shared.announcements[(indexPath as NSIndexPath).row]

        cell.titleLabel.text = announcement.title
        cell.dateLabel.text = announcement.localizedDate
        cell.messageLabel.text = announcement.message
		cell.colorView.layer.borderColor = announcement.category.color.cgColor
		cell.colorView.layer.borderWidth = cell.colorView.frame.width

		cell.sponsoredLabel.isHidden = !announcement.isSponsored

        return cell
    }
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if APIManager.shared.canEditAnnouncements() {
			let compose = storyboard!.instantiateViewController(withIdentifier: "ComposeAnnouncementViewController") as! UINavigationController
			(compose.topViewController as? ComposeAnnouncementViewController)?.editingAnnouncement = APIManager.shared.announcements[(indexPath as NSIndexPath).row]
			present(compose, animated: true, completion: nil)
		}
		else {
			tableView.deselectRow(at: indexPath, animated: true)
		}
	}
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return APIManager.shared.canEditAnnouncements()
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "✕") { action, index in
            let confirm = UIAlertController(title: "Announcement Deletion", message: "This announcement will be deleted from the approval list for all MHacks organizers.",preferredStyle: .alert)
            confirm.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            confirm.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {(action: UIAlertAction!) in
                
//                APIManager.shared.deleteAnnouncement((indexPath as NSIndexPath).row, completion: {deleted in
//                    if deleted {
//                        self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
//                    }
//                })
            }))
            self.present(confirm, animated: true, completion: nil)
        }
        delete.backgroundColor = UIColor.red
        
        return [delete]
    }
}
