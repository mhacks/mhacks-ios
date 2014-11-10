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
    
    var sponsors: [PFObject] = []
    var sponsorLogos = Dictionary<String, UIImage>()
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
        
        self.getSponsorsFromParse()
    }
    
    // MARK: Fetching data from Parse
    
    func getSponsorsFromParse() {
        
        let sponsorsQuery = PFQuery(className: "Sponsor")
        
        // I hope there's a cleaner way to do this
        sponsorsQuery.findObjectsInBackgroundWithBlock() { objects, error in
            if let objects = objects as? [PFObject] {
                self.sponsors = objects
                
                for sponsor in self.sponsors {
                    println(sponsor)
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
                
                self.collectionView.reloadData()
            } else {
                println("Couldn't fetch the sponsors!")
            }
        }
    }
    
    // MARK: Collection view data source
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sponsors.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SponsorCell", forIndexPath: indexPath) as SponsorCell
        let sponsor = self.sponsors[indexPath.row]
        
        cell.logoView.image = self.sponsorLogos[sponsor["name"] as String!]
        
        return cell
    }

}
