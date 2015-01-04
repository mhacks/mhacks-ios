//
//  MapViewController.swift
//  MHacks
//
//  Created by Ben Oztalay on 12/3/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate {
    
    // MARK: Initialization
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let observer = Observer<[Map]> { [unowned self] maps in
            self.maps = maps
        }
        
        fetchResultsManager.observerCollection.addObserver(observer)
    }
    
    // MARK: Model
    
    let fetchResultsManager: FetchResultsManager<Map> = {
        
        let query = PFQuery(className: "Map")
        
        query.orderByAscending("order")
        
        return FetchResultsManager<Map>(query: query, name: "Map")
    }()
    
    private var maps: [Map] = [] {
        didSet {
            self.pageControl?.numberOfPages = maps.count
            self.collectionView.reloadData()
        }
    }
    
    private func fetch() {
        
        if !fetchResultsManager.fetched {
            fetch(.Local)
        } else {
            fetch(.Remote)
        }
    }
    
    private func fetch(source: FetchSource) {
        
        if !fetchResultsManager.fetching {
            
            errorLabel.hidden = true
            
            if fetchResultsManager.results.isEmpty {
                loadingIndicatorView.startAnimating()
            }
            
            fetchResultsManager.fetch(source) { error in
                
                self.loadingIndicatorView.stopAnimating()
                
                if self.fetchResultsManager.results.isEmpty && error != nil {
                    self.errorLabel.hidden = false
                }
                
                if source == .Local {
                    self.fetch(.Remote)
                }
            }
        }
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet private var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var errorLabel: UILabel!
    
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
        
        fetch()
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
        
        if !map.image.isDataAvailable {
            cell.activityIndicator.startAnimating()
            cell.mapImage.image = nil
        }
        
        map.image.getDataInBackgroundWithBlock { data, error in
            
            if data != nil {
                
                if cell === collectionView.cellForItemAtIndexPath(indexPath) {
                    
                    if let image = UIImage(data: data) {
                        cell.mapImage.image = image
                    }
                }
            }
            
            cell.activityIndicator.stopAnimating()
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
