//
//  MapViewController.swift
//  MHacks
//
//  Created by Ben Oztalay on 12/3/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
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
            
            currentIndex = 0
            
            collectionView?.reloadData()
            collectionView?.contentOffset = CGPointZero
            
            pageControl?.numberOfPages = maps.count
            pageControl?.currentPage = 0
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
    
    var currentIndex: Int? {
        didSet {
            updateNavigationItemTitle()
        }
    }
    
    // MARK: View
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var errorLabel: UILabel!
    
    private func updateNavigationItemTitle() {
        navigationItem.title = (currentIndex == nil) ? nil : maps[currentIndex!].title
    }
    
    // MARK: View life cycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        fetch()
    }
    
    // MARK: Collection view data source
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return maps.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MapCell", forIndexPath: indexPath) as! MapCollectionViewCell
        
        let map = maps[indexPath.row]
        
        cell.activityIndicator.startAnimating()
        
        map.image.getDataInBackgroundWithBlock { data, error in
            
            // Allow the activity indicator to spin indefinitely if the image cannot be loaded as opposed to presenting an error label
            // An error here is such a rare case and will occur so transiently that we can just leave it spinning
            // All a user has to do is swipe to a different map and swipe back to get it to reload
            
            if data != nil {
                
                if let image = UIImage(data: data) {
                    
                    // Do not touch the cell unless it is still our cell
                    
                    if cell === collectionView.cellForItemAtIndexPath(indexPath) {
                        cell.imageView.image = image
                        cell.activityIndicator.stopAnimating()
                    }
                    
                }
            }
        }
        
        return cell
    }
    
    // MARK: Collection view delegate
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    // MARK: Scroll view delegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let index = Int(round(collectionView.contentOffset.x / collectionView.frame.width))
        
        pageControl.currentPage = index
        
        currentIndex = min(max(index, 0), maps.count - 1)
    }
    
    // MARK: Actions
    
    @IBAction func pageControlValueChanged() {
        
        let index = pageControl.currentPage
        
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: pageControl.currentPage, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: true)
        
        currentIndex = index
    }
}
