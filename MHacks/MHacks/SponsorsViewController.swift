//
//  SponsorsViewController.swift
//  MHacks
//
//  Created by Ben Oztalay on 11/5/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class SponsorsViewController: UICollectionViewController {
    
    // MARK: Model
    
    private var sponsorOrganizer: SponsorOrganizer? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    func fetchSponsors() {
        
        let query = PFQuery(className: "Sponsor")
        
        query.includeKey("tier")
        query.includeKey("location")
        
        query.fetch { (possibleSponsors: [Sponsor]?) in
            
            if let sponsors = possibleSponsors {
                
                self.sponsorOrganizer = SponsorOrganizer(sponsors: sponsors)
                
            } else {
                
                // FIXME: Handle error
            }
        }
    }
    
    // MARK: View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.registerNib(UINib(nibName: "SponsorTierHeader", bundle: nil), forSupplementaryViewOfKind: GridLayout.SupplementaryViewKind.Header.rawValue, withReuseIdentifier: "TierHeader")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchSponsors()
    }
    
    // MARK: Collection view delegate
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        println(kind)
        
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "TierHeader", forIndexPath: indexPath) as SponsorTierHeader
        
        headerView.label.text = sponsorOrganizer!.tiers[indexPath.section].name
        
        return headerView
    }
    
    // MARK: Collection view data source
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sponsorOrganizer?.tiers.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sponsorOrganizer!.sponsors[section].count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SponsorCell", forIndexPath: indexPath) as SponsorCell
        
        let sponsor = sponsorOrganizer!.sponsors[indexPath.section][indexPath.item]
        
        //sponsor.fetchLogo()
        
        cell.logoView.image = sponsor.logo
    
        return cell
    }
}
