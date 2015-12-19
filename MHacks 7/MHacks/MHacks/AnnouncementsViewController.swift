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
		guard let refreshControl = refreshControl where !(refreshControl.refreshing)
		else { return }
		refreshControl.beginRefreshing()
		APIManager.sharedManager.taskWithRoute("/v1/announcements", usingHTTPMethod: .GET, completion: { (result: Either<Array<Announcement>>) in
			defer {
				refreshControl.endRefreshing()
			}
			switch result
			{
			case .Value(let newAnnouncements):
				self.announcements = newAnnouncements
			case .NetworkingError(let error):
				// TODO: Handle error
				print(error.localizedDescription)
			case .UnknownError:
				// TODO: Handle this error
				break
			}
		})
	}
	
	private var announcements = [Announcement]() {
		didSet {
			tableView?.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
			// TODO: Set cache for announcements
		}
	}
	
    // MARK: View
	
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 98.0
		if APIManager.sharedManager.authenticator.canPostAnnouncements()
		{
			// TODO: Show compose post button
		}
    }
	
	func refresh(sender: UIRefreshControl)
	{
		fetch()
	}
	
	override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
		// TODO: Load announcements from cache
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
