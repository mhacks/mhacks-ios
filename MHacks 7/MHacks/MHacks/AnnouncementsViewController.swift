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
	
	private func fetch() {
		refreshControl?.beginRefreshing()
		// TODO: Fetch announcements
		// Remember to end refreshing on finish
	}
	
	private var announcements: [Announcement] = [] {
		didSet {
			tableView?.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
		}
	}
	
    // MARK: View
	
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 98.0
    }
	
	func refresh(sender: UIRefreshControl)
	{
		fetch()
	}
	
	override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
		fetch()
    }
    
    // MARK: Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return announcements.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath) as! AnnouncementCell
        
        let announcement = announcements[indexPath.row]
        
        cell.titleLabel.text = announcement.title
        cell.dateLabel.text = announcement.localizedDate
        cell.messageLabel.text = announcement.message
        
        return cell
    }
	
}
