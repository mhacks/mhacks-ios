//
//  AnnouncementsViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 11/18/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class AnnouncementsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Initialization
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let observer = Observer<[Announcement]> { [unowned self] announcements in
            self.announcements = announcements
        }
        
        fetchResultsManager.observerCollection.addObserver(observer)
    }
    
    // MARK: Model
    
    let fetchResultsManager: FetchResultsManager<Announcement> = {
        
        let query = PFQuery(className: "Announcement")
        
        query.orderByDescending("date")
        
        return FetchResultsManager<Announcement>(query: query, name: "Announcements")
    }()
    
    
    private var announcements: [Announcement] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private func fetch(source: FetchSource) {
        
        if !fetchResultsManager.fetching {
            
            errorLabel.hidden = true
            
            if fetchResultsManager.results.isEmpty {
                tableView.hidden = true
                loadingIndicatorView.startAnimating()
            }
            
            fetchResultsManager.fetch(source) { error in
                
                self.loadingIndicatorView.stopAnimating()
                
                if self.fetchResultsManager.results.isEmpty && error != nil {
                    self.errorLabel.hidden = false
                } else {
                    self.tableView.hidden = false
                }
            }
        }
    }
    
    // MARK: View
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet private var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 98.0
        
        fetch(.Local)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        fetch(.Remote)
    }
    
    // MARK: Table view
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return announcements.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Announcement Cell", forIndexPath: indexPath) as AnnouncementCell
        
        let announcement = announcements[indexPath.row]
        
        cell.titleLabel.text = announcement.title
        cell.dateLabel.text = announcement.localizedDate
        cell.messageLabel.text = announcement.message
        
        return cell
    }
}
