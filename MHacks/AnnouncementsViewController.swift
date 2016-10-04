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
	
	fileprivate func fetch(completionBlock: (() -> Void)? = nil) {
		APIManager.shared.updateAnnouncements { _ in
			DispatchQueue.main.async(execute: {
				completionBlock?()
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
		
        if APIManager.shared.canPostAnnouncements {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(AnnouncementsViewController.compose(_:)))
        }
        else {
            navigationItem.rightBarButtonItem = nil
        }
		
		NotificationCenter.default.addObserver(self, selector: #selector(AnnouncementsViewController.announcementsUpdated(_:)), name: APIManager.AnnouncementsUpdatedNotification, object: nil)
		
		if APIManager.shared.canEditAnnouncements {
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
		
		fetch()
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Actions/Notifications
	
	func refresh(_ sender: UIRefreshControl) {
		
		fetch {
			sender.endRefreshing()
		}
	}
	
	func announcementsUpdated(_ notification: Notification? = nil) {
		DispatchQueue.main.async(execute: {
			CATransaction.begin()
			self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
			CATransaction.commit()
		})
	}
	
	func compose(_ sender: UIBarButtonItem) {
		guard APIManager.shared.canPostAnnouncements
		else {
			navigationItem.rightBarButtonItem = nil
			return
		}
		let compose = storyboard!.instantiateViewController(withIdentifier: "ComposeAnnouncementNavigationController") as! UINavigationController
		present(compose, animated: true, completion: nil)
	}
	
    // MARK: Table View Data
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return APIManager.shared.announcements.count
    }
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Announcement Cell", for: indexPath) as! AnnouncementCell
        let announcement = APIManager.shared.announcements[(indexPath as NSIndexPath).row]

		cell.selectionStyle = .none
        cell.title.text = announcement.title
        cell.date.text = announcement.localizedDate
        cell.message.text = announcement.message
		
		cell.colorView.backgroundColor = announcement.category.color

		cell.sponsored.isHidden = !announcement.isSponsored
		cell.unapproved.isHidden = !announcement.approved && APIManager.shared.canEditAnnouncements ? false : true

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return APIManager.shared.canEditAnnouncements
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let edit = UITableViewRowAction(style: .default, title: "Edit") { action, index in
			let compose = self.storyboard!.instantiateViewController(withIdentifier: "ComposeAnnouncementNavigationController") as! UINavigationController
			(compose.topViewController as? ComposeAnnouncementTableViewController)?.editingAnnouncement = APIManager.shared.announcements[indexPath.row]
			self.present(compose, animated: true, completion: nil)
		}
		
		edit.backgroundColor = MHacksColor.plain
		
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            let confirm = UIAlertController(title: "Announcement Deletion", message: "This announcement will be deleted from the approval list for all MHacks organizers.", preferredStyle: .alert)
            confirm.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            confirm.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {(action: UIAlertAction!) in
				APIManager.shared.deleteAnnouncement(APIManager.shared.announcements[indexPath.row])
			}))
			
            self.present(confirm, animated: true, completion: nil)
        }
		
		if !APIManager.shared.announcements[indexPath.row].approved {
			let approve = UITableViewRowAction(style: .default, title: "Approve", handler: { action, index in
				let confirm = UIAlertController(title: "Announcement Approval", message: "This announcement will be added to the approval list", preferredStyle: .alert)
				confirm.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
				confirm.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {(action: UIAlertAction!) in
					var approvedAnnouncement = APIManager.shared.announcements[indexPath.row]
					approvedAnnouncement.approved = true
					APIManager.shared.updateAnnouncement(approvedAnnouncement, usingMethod: .put)
				}))
				
				self.present(confirm, animated: true, completion: nil)
			})
			
			approve.backgroundColor = UIColor(red: 27.0 / 255, green: 188.0 / 255.0, blue: 155.0 / 255.0, alpha: 1.0)
			
			return [approve, delete, edit]
		}
        
        return [delete, edit]
    }
}
