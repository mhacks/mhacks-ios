//
//  BuildingMapsViewController.swift
//  MHacks
//
//  Created by Gurnoor Singh on 9/16/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class BuildingMapsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: Views
    
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        floorsUpdated(Notification(name: APIManager.FloorsUpdatedNotification))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(floorsUpdated(_:)), name: APIManager.FloorsUpdatedNotification, object: nil)
        
        APIManager.shared.updateFloors()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: APIManager.FloorsUpdatedNotification, object: nil)
    }
    
    // MARK: Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return APIManager.shared.floors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let floorCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Floor Cell", for: indexPath) as! FloorCell
        
        let floor = APIManager.shared.floors[indexPath.item]
        
        floor.retrieveImage { image in
            DispatchQueue.main.async {
                
                if collectionView.indexPath(for: floorCell) == indexPath {
                    floorCell.imageView.image = image
                }
            }
        }
        
        return floorCell
    }
    
    // MARK: Collection view delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
    
    // MARK: Notifications
    
    func floorsUpdated(_ : Notification) {
        
        DispatchQueue.main.async {
            
            if self.isViewLoaded {
                self.collectionView.reloadData()
            }
        }
    }
}
