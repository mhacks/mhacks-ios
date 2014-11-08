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
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The static analyzer was having fun
        let thing = self.collectionView
        let thingy = thing.frame
        let thingyy = Double(thingy.width)
        
        let cellSpacing = Double(1.0 / UIScreen.mainScreen().scale)
        let rawCellSize = thingyy / numberOfColumns
        let cellSize = rawCellSize - (((numberOfColumns - 1.0) * cellSpacing) / numberOfColumns)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(CGFloat(cellSize), CGFloat(cellSize))
        flowLayout.minimumLineSpacing = CGFloat(cellSpacing)
        flowLayout.minimumInteritemSpacing = CGFloat(cellSpacing)
        
        self.collectionView.collectionViewLayout = flowLayout
    }
    
    // MARK: Collection view data source
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SponsorCell", forIndexPath: indexPath) as SponsorCell
        
        cell.label.text = "\(indexPath.row)"
        cell.backgroundColor = UIColor.redColor()
        
        return cell
    }

}
