//
//  FloorLayout.swift
//  MHacks
//
//  Created by Russell Ladd on 10/1/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

final class FloorLayout: UICollectionViewLayout {
    
    var floorHeight: CGFloat = 100.0
    
    var contentSize = CGSize.zero
    
    override func prepare() {
        super.prepare()
        
        guard  let collectionView = collectionView else {
            return
        }
        
        let numberOfFloors = collectionView.numberOfItems(inSection: 0)
        
        contentSize = CGSize(width: collectionView.bounds.width, height: CGFloat(numberOfFloors) * floorHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        return (0..<collectionView!.numberOfItems(inSection: 0)).map { item in
            return layoutAttributesForItem(at: IndexPath(item: item, section: 0))!
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        layoutAttributes.frame = CGRect(x: 0.0, y: CGFloat(indexPath.item) * floorHeight, width: contentSize.width, height: floorHeight)
        
        // Lower rows should appear underneath higher rows
        layoutAttributes.zIndex = -indexPath.item
        
        return layoutAttributes
    }
}
