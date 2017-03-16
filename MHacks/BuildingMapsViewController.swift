//
//  BuildingMapsViewController.swift
//  MHacks
//
//  Created by Gurnoor Singh on 9/16/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit
import MapKit

class BuildingMapsViewController: UIViewController, UICollectionViewDataSource, FloorLayoutDelegate {
    
    // MARK: Views
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var floorLayout: FloorLayout!
    @IBOutlet var demoteGestureRecognizer: UITapGestureRecognizer!
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "FloorDescription", bundle: nil), forSupplementaryViewOfKind: FloorLayout.SupplementaryViewKind.Description.rawValue, withReuseIdentifier: "Description View")
        collectionView.register(UINib(nibName: "FloorLabel", bundle: nil), forSupplementaryViewOfKind: FloorLayout.SupplementaryViewKind.Label.rawValue, withReuseIdentifier: "Label View")
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
    
    // MARK: Update promoted item
    
    func updatePromotedFloor(_ promotedFloor: Int?) {
        
        demoteGestureRecognizer.isEnabled = (promotedFloor != nil)
        
        collectionView.performBatchUpdates({
            
            if let promotedFloor = promotedFloor {
                self.floorLayout.promotedItems = [promotedFloor]
            } else {
                self.floorLayout.promotedItems = []
            }
            
            self.collectionView.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    // MARK: Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return APIManager.shared.floors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let floorCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Floor Cell", for: indexPath) as! IndoorFloorCell

        let floor = APIManager.shared.floors[indexPath.item]
        
        floorCell.imageView.alpha = 0.0
        
        floor.retrieveImage { image in
            DispatchQueue.main.async {
                
                if collectionView.indexPath(for: floorCell) == indexPath {
                    floorCell.imageView.image = image
                    
                    let offsetFromBottom = collectionView.numberOfItems(inSection: 0) - 1 - indexPath.item
                    
                    UIView.animate(withDuration: 0.15, delay: TimeInterval(offsetFromBottom) * 0.05, options: [], animations: {
                        floorCell.imageView.alpha = 1.0
                    }, completion: nil)

                }
            }
        }
        
        return floorCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let floor = APIManager.shared.floors[indexPath.item]
        
        let view: UICollectionReusableView
        
        switch FloorLayout.SupplementaryViewKind(rawValue: kind)! {
            
        case .Description:
            
            let descriptionView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Description View", for: indexPath) as! FloorDescriptionView
            
            descriptionView.label.text = floor.description
            
            view = descriptionView
            
        case .Label:
            
            let labelView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Label View", for: indexPath) as! FloorLabelView
            
            if floor.name.isEmpty {
                labelView.label.text = nil
            } else {
                labelView.label.text = String(floor.name.characters[floor.name.startIndex])
            }
            
            view = labelView
        }
        
        return view
    }
    
    // MARK: Collection view delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        updatePromotedFloor(floorLayout.promotedItems.isEmpty ? indexPath.item : nil)
    }
    
    // MARK: Floor layout delegate
    
    func collectionView(_ collectionView: UICollectionView, floorLayout: FloorLayout, offsetFractionForItemAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(APIManager.shared.floors[indexPath.item].offsetFraction)
    }
    
    func collectionView(_ collectionView: UICollectionView, floorLayout: FloorLayout, aspectRatioForItemAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(APIManager.shared.floors[indexPath.item].aspectRatio)
    }
    
    // MARK: Actions
    
    @IBAction func demoteFloor() {
        
        updatePromotedFloor(nil)
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
