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
    
    private var announcements: [Announcement]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private func fetchAnnouncements() {
        
        let query = PFQuery(className: "Announcement")
        
        query.orderByDescending("date")
        
        query.fetch { (possibleAnnouncements: [Announcement]?) in
            
            if let announcements = possibleAnnouncements {
                
                self.announcements = announcements
                
            } else {
                
                // FIXME: Handle error
            }
        }
    }
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 98.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchAnnouncements()
    }
    
    // MARK: Table view
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return announcements?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Announcement Cell", forIndexPath: indexPath) as AnnouncementCell
        
        let announcement = announcements![indexPath.row]
        
        cell.titleLabel.text = announcement.title
        cell.dateLabel.text = announcement.localizedDate
        cell.messageLabel.text = announcement.message
        
        return cell
    }
}
