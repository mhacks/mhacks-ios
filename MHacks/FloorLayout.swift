//
//  FloorLayout.swift
//  MHacks
//
//  Created by Russell Ladd on 10/1/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

protocol FloorLayoutDelegate: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, floorLayout: FloorLayout, offsetFractionForItemAt indexPath: IndexPath) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, floorLayout: FloorLayout, aspectRatioForItemAt indexPath: IndexPath) -> CGFloat
}

final class FloorLayout: UICollectionViewLayout {
    
    enum SupplementaryViewKind: String {
        case Description = "Description"
        case Label = "Label"
    }
    
    var promotedItems = IndexSet() {
        didSet {
            invalidateLayout()
        }
    }
    
    var explodesFromFirstPromotedItem = true {
        didSet {
            invalidateLayout()
        }
    }
    
    var sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0) {
        didSet {
            invalidateLayout()
        }
    }
    
    var labelInset: CGFloat = 15.0 {
        didSet {
            invalidateLayout()
        }
    }
    
    private var delegate: FloorLayoutDelegate? {
        return collectionView?.delegate as? FloorLayoutDelegate
    }
    
    private var contentSize = CGSize.zero
    
    private var offsetFractions = [CGFloat]()
    private var aspectRatios = [CGFloat]()
    
    private var sectionSize: CGSize {
        return CGSize(width: contentSize.width - sectionInsets.left - sectionInsets.left,
                      height: contentSize.height - sectionInsets.top - sectionInsets.bottom)
    }
    
    private var verticalCompressionFactor: CGFloat = 1.0
    
    override func prepare() {
        super.prepare()
        
        guard  let collectionView = collectionView, let delegate = delegate else {
            return
        }
        
        contentSize = UIEdgeInsetsInsetRect(collectionView.bounds, collectionView.contentInset).size
        
        let numberOfFloors = collectionView.numberOfItems(inSection: 0)
        
        offsetFractions = (0..<numberOfFloors).map { item in
            return delegate.collectionView(collectionView, floorLayout: self, offsetFractionForItemAt: [0, item])
        }
        
        aspectRatios = (0..<numberOfFloors).map { item in
            return delegate.collectionView(collectionView, floorLayout: self, aspectRatioForItemAt: [0, item])
        }
        
        if let lastFraction = offsetFractions.last, let lastRatio = aspectRatios.last {
            
            let lastTop = sectionSize.height * lastFraction
            
            let maxHeight = lastTop + sectionSize.width / lastRatio
            
            let overshoot = maxHeight - sectionSize.height
            
            verticalCompressionFactor = (lastTop - overshoot) / lastTop
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let cellAttributes: [UICollectionViewLayoutAttributes] = (0..<collectionView!.numberOfItems(inSection: 0)).map { item in
            return layoutAttributesForItem(at: [0, item])!
        }
        
        let descriptionViewAttributes: [UICollectionViewLayoutAttributes] = (0..<collectionView!.numberOfItems(inSection: 0)).map { item in
            return layoutAttributesForSupplementaryView(ofKind: SupplementaryViewKind.Description.rawValue, at: [0, item])!
        }
        
        let labelViewAttributes: [UICollectionViewLayoutAttributes] = (0..<collectionView!.numberOfItems(inSection: 0)).map { item in
            return layoutAttributesForSupplementaryView(ofKind: SupplementaryViewKind.Label.rawValue, at: [0, item])!
        }
        
        return cellAttributes + descriptionViewAttributes + labelViewAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        let offsetFraction = offsetFractions[indexPath.item]
        let aspectRatio = aspectRatios[indexPath.item]
        
        layoutAttributes.frame = CGRect(x: sectionInsets.left, y: sectionInsets.top + sectionSize.height * offsetFraction * verticalCompressionFactor, width: sectionSize.width, height: sectionSize.width / aspectRatio)
        
        if !promotedItems.isEmpty && !promotedItems.contains(indexPath.item) {
            layoutAttributes.alpha = 0.1
        }
        
        if let promotedItem = promotedItems.first, explodesFromFirstPromotedItem {
            
            if indexPath.item != promotedItem {
                
                let delta = indexPath.item - promotedItem
                let sign = abs(delta) / delta
                let inverseDistance = collectionView!.numberOfItems(inSection: 0) - abs(delta)
                let inverseDelta = sign * inverseDistance
                
                layoutAttributes.frame.origin.y += CGFloat(inverseDelta) * 20.0
                
            } else {
                
                // Average position with the middle
                
                let originalY = layoutAttributes.frame.origin.y
                let middleY = sectionInsets.top + (sectionSize.height - sectionSize.width / aspectRatio) / 2.0
                
                layoutAttributes.frame.origin.y = originalY * 0.4 + middleY * 0.6
            }
        }
        
        // Lower rows should appear underneath higher rows
        layoutAttributes.zIndex = -indexPath.item
        
        return layoutAttributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        
        switch SupplementaryViewKind(rawValue: elementKind)! {
            
        case .Description:
            
            layoutAttributes.frame = layoutAttributesForItem(at: indexPath)!.frame
            layoutAttributes.frame.origin.y += layoutAttributes.frame.height + 10.0
            
            layoutAttributes.alpha = (promotedItems.contains(indexPath.item) && explodesFromFirstPromotedItem) ? 1.0 : 0.0
            
            layoutAttributes.zIndex = 1

        case .Label:
            
            layoutAttributes.frame = layoutAttributesForItem(at: indexPath)!.frame
            layoutAttributes.frame.origin.x += labelInset
            layoutAttributes.frame.origin.y += (layoutAttributes.frame.height - 22.0) * 0.4
            layoutAttributes.frame.size = CGSize(width: 22.0, height: 22.0)
            
            if !promotedItems.isEmpty && !promotedItems.contains(indexPath.item) {
                layoutAttributes.alpha = explodesFromFirstPromotedItem ? 0.0 : 0.2
            }
        }
        
        return layoutAttributes
    }
}
