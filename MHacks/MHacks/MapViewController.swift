//
//  MapViewController.swift
//  MHacks
//
//  Created by Ben Oztalay on 12/3/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: Model
    
    private var maps: [Map] = [] {
        didSet {
            self.pageControl?.numberOfPages = maps.count
            self.collectionView.reloadData()
        }
    }
    
    func fetchMaps() {
        
        let query = PFQuery(className: "Map")
        
        query.orderByDescending("order")
        
        query.fetch { (possibleMaps: [Map]?) in
            
            if let maps = possibleMaps {
                
                self.maps = maps
                
            } else {
                
                // FIXME: Handle error
            }
        }
    }
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCollectionViewLayout()
    }
    
    func setUpCollectionViewLayout() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        
        self.collectionView?.pagingEnabled = true
        self.collectionView?.collectionViewLayout = flowLayout
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchMaps()
    }
    
    // MARK: Collection view data source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return maps.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = self.collectionView?.dequeueReusableCellWithReuseIdentifier("MapCell", forIndexPath: indexPath) as MapCollectionViewCell!
        
        let map = maps[indexPath.row]
        
        map.image.getDataInBackgroundWithBlock { data, error in
            
            if data != nil {
                
                if cell === collectionView.cellForItemAtIndexPath(indexPath) {
                    
                    if let image = UIImage(data: data) {
                        cell.mapImage.image = image
                    }
                }
            }
        }
        
        return cell
    }
    
    // MARK: Collection view delegate
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(self.collectionView!.frame.width, self.collectionView!.frame.height)
    }
    
    // MARK: Scroll view delegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.width
        self.pageControl.currentPage = Int(currentIndex)
    }
}
