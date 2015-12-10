//
//  SponsorViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 12/9/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

class SponsorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Model
    
    var sponsor: Sponsor? {
        didSet {
            updateLabels()
        }
    }
    
    // MARK: View
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tierLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewSeparatorHeightConstrait: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layoutMargins = Geometry.Insets
        
        updateLabels()
    }
    
    let imageResizingQueue = NSOperationQueue()
    
    func updateLabels() {
        
        if !isViewLoaded() {
            return
        }
        
        if let sponsor = sponsor {
            
            sponsor.logo.getDataInBackgroundWithBlock { data, error in
                
                if data != nil {
                    
                    let logoViewSize = self.logoView.bounds.size
                    
                    self.imageResizingQueue.addOperationWithBlock {
                        
                        if let image = UIImage(data: data) {
                            
                            let resizedImage = image.resizedImageWithSize(logoViewSize)
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                
                                if self.sponsor == sponsor {
                                    self.logoView.image = resizedImage
                                }
                            }
                        }
                    }
                }
            }
            
            nameLabel.text = sponsor.name
            tierLabel.text = sponsor.tier.name
            locationLabel.text = sponsor.location.name
            descriptionLabel.text = sponsor.description
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        tableViewSeparatorHeightConstrait.constant = Geometry.hairlineWidthInTraitCollection(traitCollection)
    }
    
    // MARK: Table view
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("Website Cell", forIndexPath: indexPath) 
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        UIApplication.sharedApplication().openURL(sponsor!.website)
    }
}
