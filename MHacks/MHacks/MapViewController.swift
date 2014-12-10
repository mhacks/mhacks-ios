//
//  MapViewController.swift
//  MHacks
//
//  Created by Ben Oztalay on 12/3/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate {
    
    let MapCellReuseIdentifier = "MapCell"
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var imageNames: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        imageNames = ["map-all", "map-beyster", "map-eecs", "map-ggbrown"]
        self.pageControl?.numberOfPages = imageNames.count
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        self.collectionView?.pagingEnabled = true
        self.collectionView?.collectionViewLayout = flowLayout
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = self.collectionView?.dequeueReusableCellWithReuseIdentifier(MapCellReuseIdentifier, forIndexPath: indexPath) as MapCollectionViewCell!
        
        cell.mapImage.image = UIImage(named: imageNames[indexPath.row])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(self.collectionView!.frame.width, self.collectionView!.frame.height)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.width
        self.pageControl.currentPage = Int(currentIndex)
    }
}
