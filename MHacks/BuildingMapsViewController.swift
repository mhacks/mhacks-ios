//
//  BuildingMapsViewController.swift
//  MHacks
//
//  Created by Gurnoor Singh on 9/16/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class BuildingMapsViewController: UIViewController, UICollectionViewDataSource, FloorLayoutDelegate {
    
    // MARK: Views
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var floorLayout: FloorLayout!
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "FloorDescription", bundle: nil), forSupplementaryViewOfKind: FloorLayout.SupplementaryViewKind.Description.rawValue, withReuseIdentifier: "Description View")
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
    
    override func viewDidLayoutSubviews() {
        
        collectionView.contentInset = UIEdgeInsets(top: 100.0 + topLayoutGuide.length, left: 0.0, bottom: 100.0 + topLayoutGuide.length, right: 0.0)
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Description View", for: indexPath) as! FloorDescriptionView
        
        let floor = APIManager.shared.floors[indexPath.item]
        
        view.label.text = floor.name
        
        return view
    }
    
    // MARK: Collection view delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.performBatchUpdates({
            
            self.floorLayout.promotedItem = (self.floorLayout.promotedItem == nil) ? indexPath.item : nil
            self.collectionView.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    // MARK: Floor layout delegate
    
    func collectionView(_ collectionView: UICollectionView, floorLayout: FloorLayout, offsetFractionForItemAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(APIManager.shared.floors[indexPath.item].offsetFraction)
    }
    
    func collectionView(_ collectionView: UICollectionView, floorLayout: FloorLayout, aspectRatioForItemAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(APIManager.shared.floors[indexPath.item].aspectRatio)
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
