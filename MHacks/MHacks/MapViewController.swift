//
//  MapViewController.swift
//  MHacks
//
//  Created by Ben Oztalay on 12/3/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let MapCellReuseIdentifier = "MapCell"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var imageTitles: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        imageTitles = ["North Campus", "Beyster Building", "EECS Building", "GG Brown Lab"]
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.itemSize = CGSizeMake(self.collectionView!.frame.width, self.collectionView!.frame.height)
        self.collectionView?.pagingEnabled = true
        self.collectionView?.collectionViewLayout = flowLayout
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageTitles.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = self.collectionView?.dequeueReusableCellWithReuseIdentifier(MapCellReuseIdentifier, forIndexPath: indexPath) as MapCollectionViewCell!
        
        cell.mapTitle.text = imageTitles[indexPath.row]
        
        return cell
    }
}
