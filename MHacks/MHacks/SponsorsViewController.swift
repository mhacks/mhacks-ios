//
//  SponsorsViewController.swift
//  MHacks
//
//  Created by Ben Oztalay on 11/5/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class SponsorsViewController: UICollectionViewController {
    
    // MARK: Constants
    
    let numberOfColumns = 3.0
    let cellSpacing = 7.0
    
    // MARK: State
    
    var sponsorsByTier = Dictionary<String, [PFObject]>()
    var sponsorTiers = [PFObject]()
    var sponsorLogos = Dictionary<String, UIImage>()
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set up the size of the cells
        
        // The static analyzer was having fun, thought self.collectionView referred to a method
        let thing = self.collectionView
        let thingy = thing.frame
        let thingyy = Double(thingy.width)
        
        let rawCellSize = thingyy / numberOfColumns
        let cellSize = rawCellSize - (((numberOfColumns + 1.0) * cellSpacing) / numberOfColumns)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(CGFloat(cellSize), CGFloat(cellSize))
        flowLayout.minimumLineSpacing = CGFloat(cellSpacing)
        flowLayout.minimumInteritemSpacing = CGFloat(cellSpacing)
        
        self.collectionView.collectionViewLayout = flowLayout
        let cgCellSpacing = CGFloat(cellSpacing)
        self.collectionView.contentInset = UIEdgeInsets(top: cgCellSpacing, left: cgCellSpacing, bottom: cgCellSpacing, right: cgCellSpacing)
        
        // Register the separator view
        
        self.collectionView.registerNib(UINib(nibName: "SponsorTierSeparator", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SponsorTierSeparator")
       
        self.getSponsorsFromParse()
    }
    
    // MARK: Fetching data from Parse
    
    func getSponsorsFromParse() {
        
        let sponsorsQuery = PFQuery(className: "Sponsor")
        sponsorsQuery.includeKey("location")
        sponsorsQuery.includeKey("tier")
        
        sponsorsQuery.findObjectsInBackgroundWithBlock() { objects, error in
            if let objects = objects as? [PFObject] {
                for sponsor in objects {
                    let sponsorTier = sponsor["tier"] as PFObject
                    let sponsorTierName = sponsorTier["name"] as String
                    
                    var sponsorsInTier = self.sponsorsByTier[sponsorTierName]
                    if sponsorsInTier == nil { // TODO: is this necessary?
                        sponsorsInTier = []
                        self.sponsorTiers.append(sponsorTier)
                    }
                    
                    sponsorsInTier?.append(sponsor)
                    self.sponsorsByTier[sponsorTierName] = sponsorsInTier // TODO: Get the array by reference?
                }
                
                self.collectionView.reloadData()
                
                // Doing this here to force ordering on reloading the collectionView (images were getting loaded too quickly)
                for sponsor in objects {
                    self.fetchLogoForSponsor(sponsor)
                }
            } else {
                println("Couldn't fetch the sponsors!")
            }
        }
    }
    
    func fetchLogoForSponsor(sponsor: PFObject) {
        
        let logoImageFile = sponsor["logo"] as? PFFile
        
        if let logoImageFile = logoImageFile {
            logoImageFile.getDataInBackgroundWithBlock { data, error in
                if let data = data {
                    let logoImage = UIImage(data: data)
                    self.sponsorLogos[sponsor["name"] as String!] = logoImage
                }
                
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: Collection view delegate
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        println(kind)
        
        if kind == UICollectionElementKindSectionHeader {
            var headerView = self.collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "SponsorTierSeparator", forIndexPath: indexPath) as SponsorTierSeparator
            let sponsorTier = self.sponsorTiers[indexPath.section]
            let sponsorTierName = sponsorTier["name"] as String
            
            headerView.label.text = sponsorTierName
            
            return headerView
        } else {
            return self.collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "FooterView", forIndexPath: indexPath) as UICollectionReusableView
        }
    }
    
    // MARK: Collection view data source
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.sponsorTiers.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sponsorTier = self.sponsorTiers[section]
        let sponsorTierName = sponsorTier["name"] as String
        let sponsorsInTier = self.sponsorsByTier[sponsorTierName]
        return sponsorsInTier!.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SponsorCell", forIndexPath: indexPath) as SponsorCell
        
        let sponsorTier = sponsorsByTier.keys.array[indexPath.section]
        let sponsorsInTier = self.sponsorsByTier[sponsorTier] as [PFObject]!
        let sponsor = sponsorsInTier[indexPath.row]
        
        cell.logoView.image = self.sponsorLogos[sponsor["name"] as String!]
        
        return cell
    }

}
