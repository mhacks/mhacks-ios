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
    
    private var announcements: [Announcement]?
    
    private func fetchAnnouncements() {
        
        let query = PFQuery(className: "Announcement")
        
        query.orderByDescending("time")
        
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
        
        tableView.estimatedRowHeight = 98.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchAnnouncements()
    }
}
