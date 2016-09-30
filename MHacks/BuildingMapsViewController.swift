//
//  BuildingMapsViewController.swift
//  MHacks
//
//  Created by Gurnoor Singh on 9/16/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class BuildingMapsViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(floorsUpdated(_:)), name: APIManager.FloorsUpdatedNotification, object: nil)
        
        self.scrollView.frame = CGRect(origin: CGPoint.zero, size: view.frame.size)
        self.scrollView.delegate = self
        self.pageControl.currentPage = 0
        floorsUpdated(Notification(name: APIManager.FloorsUpdatedNotification))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        APIManager.shared.updateFloors()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let currentPage = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
        pageControl.currentPage = Int(currentPage);
        navigationItem.title = APIManager.shared.floors[currentPage].name
    }
    func floorsUpdated(_ : Notification)
    {
        DispatchQueue.main.async {
            let count = APIManager.shared.floors.count
            self.pageControl.numberOfPages = count
            self.scrollView.subviews.forEach { $0.removeFromSuperview() }
            
            let scrollViewWidth = self.scrollView.frame.width
            let scrollViewHeight = self.scrollView.frame.width
            for (i, floor) in APIManager.shared.floors.enumerated()
            {
                let imageView = UIImageView(frame: CGRect(x: (scrollViewWidth * CGFloat(i)) + 50,
                                                          y: 40,
                                                          width: scrollViewWidth - 100,
                                                          height: scrollViewHeight - 200))
                if i == self.pageControl.currentPage
                {
                    self.navigationItem.title = floor.name
                }
                floor.retrieveImage { image in
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
                self.scrollView.addSubview(imageView)
            }
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width * CGFloat(count), height: 1.0)
        }
    }

}
