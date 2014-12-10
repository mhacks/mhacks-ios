//
//  SponsorViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 12/9/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

class SponsorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: View
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tierLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layoutMargins = Geometry.Insets
    }
    
    // MARK: Table view
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("Website Cell", forIndexPath: indexPath) as UITableViewCell
    }
}
