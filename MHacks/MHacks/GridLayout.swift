//
//  GridLayout.swift
//  MHacks
//
//  Created by Russell Ladd on 11/19/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

@objc protocol GridLayoutDelegate: UICollectionViewDelegate {
    
    optional func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, minimumItemSideLengthForSection section: Int) -> CGFloat
}

class GridLayout: UICollectionViewLayout {
    
    // MARK: Constants
    
    enum SupplementaryViewKind: String {
        case Header = "Header"
    }
    
    private enum DecorationViewKind: String {
        case ColumnSeparator = "ColumnSeparator"
        case RowSeparator = "RowSeparator"
    }
    
    // MARK: Delegate
    
    private var delegate: GridLayoutDelegate? {
        return collectionView?.delegate as? GridLayoutDelegate
    }
    
    // MARK: Properties
    
    var minimumItemSideLength: CGFloat = 50.0 {
        didSet {
            invalidateLayout()
        }
    }
    
    var headerHeight: CGFloat = 22.0 {
        didSet {
            invalidateLayout()
        }
    }
    
    // MARK: Layout calculations
    
    private func heightForSection(section: Int) -> CGFloat {
        return headerHeight + CGFloat(numberOfRowsBySection[section]) * itemSideLengthsBySection[section] + CGFloat(max(numberOfRowsBySection[section] - 1, 0)) * separatorWidth
    }
    
    private func heightForSections(sections: Range<Int>) -> CGFloat {
        return reduce(sections, 0.0) { offset, section in
            return offset + self.heightForSection(section)
        }
    }
    
    // MARK: Cache
    
    private func sectionRange() -> Range<Int> {
        return 0..<collectionView!.numberOfSections()
    }
    
    private func itemRangeForSection(section: Int) -> Range<Int> {
        return 0..<collectionView!.numberOfItemsInSection(section)
    }
    
    private var minimumItemSideLengthsBySection: [CGFloat] = []
    private var separatorWidth: CGFloat = 0.0
    private var itemSideLengthsBySection: [CGFloat] = []
    private var numberOfColumnsBySection: [Int] = []
    private var numberOfRowsBySection: [Int] = []
    
    private var contentSize = CGSizeZero
    
    private var cellLayoutAttributes: [[UICollectionViewLayoutAttributes]] = []
    private var supplementaryViewLayoutAttributes: [SupplementaryViewKind: [[UICollectionViewLayoutAttributes]]] = [:]
    private var decorationViewLayoutAttributes: [DecorationViewKind: [[UICollectionViewLayoutAttributes]]] = [:]
    
    // MARK: Layout
    
    override func prepareLayout() {
        
        minimumItemSideLengthsBySection = sectionRange().map { section in
            return self.delegate!.collectionView?(self.collectionView!, layout: self, minimumItemSideLengthForSection: section) ?? self.minimumItemSideLength
        }
        
        let contentWidth = collectionView!.bounds.width
        separatorWidth = GridLayoutSeparator.widthInTraitCollection(collectionView!.traitCollection)
        
        numberOfColumnsBySection = minimumItemSideLengthsBySection.map { length in
            return Int((contentWidth - length) / (length + self.separatorWidth)) + 1
        }
        
        numberOfRowsBySection = sectionRange().map { section in
            return Int(ceil(Double(self.collectionView!.numberOfItemsInSection(section)) / Double(self.numberOfColumnsBySection[section])))
        }
        
        itemSideLengthsBySection = sectionRange().map { section in
            return (contentWidth - CGFloat(self.numberOfColumnsBySection[section] - 1) * self.separatorWidth) / CGFloat(self.numberOfColumnsBySection[section])
        }
        
        contentSize = CGSize(width: collectionView!.bounds.width, height: heightForSections(sectionRange()))
        
        cellLayoutAttributes = sectionRange().map { section in
            
            let numberOfColumns = self.numberOfColumnsBySection[section]
            let numberOfRows = self.numberOfRowsBySection[section]
            let itemSideLength = self.itemSideLengthsBySection[section]
            let sectionOffset = self.heightForSections(0..<section)
            
            return map(self.itemRangeForSection(section)) { item in
                
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                
                let layoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                
                let column = item % numberOfColumns
                let row = item / numberOfColumns
                
                let rect = CGRect(x: CGFloat(column) * (itemSideLength * self.separatorWidth), y: sectionOffset + self.headerHeight + CGFloat(row) * (itemSideLength + self.separatorWidth), width: itemSideLength, height: itemSideLength)
                
                layoutAttributes.frame = rect.integratedRectInTraitCollection(self.collectionView!.traitCollection)
                
                return layoutAttributes
            }
        }
        
        supplementaryViewLayoutAttributes[.Header] = sectionRange().map { section in
            
            let layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SupplementaryViewKind.Header.rawValue, withIndexPath: NSIndexPath(forItem: 0, inSection: section))
            
            let sectionOffset = self.heightForSections(0..<section)
            
            let rect = CGRect(x: 0.0, y: sectionOffset, width: contentWidth, height: self.headerHeight)
            
            layoutAttributes.frame = rect.integratedRectInTraitCollection(self.collectionView!.traitCollection)
            
            return [layoutAttributes]
        }
        
        decorationViewLayoutAttributes[.ColumnSeparator] = sectionRange().map { section in
            
            let numberOfColumns = self.numberOfColumnsBySection[section]
            let itemSideLength = self.itemSideLengthsBySection[section]
            let sectionOffset = self.heightForSections(0..<section)
            let height = self.heightForSection(section)
            
            let range = 0..<(numberOfColumns - 1)
            
            return range.map { item in
                
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                
                let layoutAttributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: DecorationViewKind.ColumnSeparator.rawValue, withIndexPath: indexPath)
                
                let rect = CGRect(x: itemSideLength + CGFloat(item) * (self.separatorWidth + itemSideLength), y: sectionOffset + self.headerHeight, width: self.separatorWidth, height: height)
                
                layoutAttributes.frame = rect.integratedRectInTraitCollection(self.collectionView!.traitCollection)
                
                return layoutAttributes
            }
        }
        
        decorationViewLayoutAttributes[.RowSeparator] = sectionRange().map { section in
            
            let numberOfRows = self.numberOfRowsBySection[section]
            let itemSideLength = self.itemSideLengthsBySection[section]
            let sectionOffset = self.heightForSections(0..<section)
            
            let range = 0..<(numberOfRows - 1)
            
            return range.map { item in
                
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                
                let layoutAttributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: DecorationViewKind.RowSeparator.rawValue, withIndexPath: indexPath)
                
                let rect = CGRect(x: 0.0, y: sectionOffset + self.headerHeight + itemSideLength + CGFloat(item) * (self.separatorWidth + itemSideLength), width: contentWidth, height: self.separatorWidth)
                
                layoutAttributes.frame = rect.integratedRectInTraitCollection(self.collectionView!.traitCollection)
                
                return layoutAttributes
            }
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        
        return reduce(sectionRange(), [UICollectionViewLayoutAttributes]()) { layoutAttributes, section in
            return layoutAttributes + self.cellLayoutAttributes[section] + self.supplementaryViewLayoutAttributes[.Header]![section] + self.decorationViewLayoutAttributes[.ColumnSeparator]![section] + self.decorationViewLayoutAttributes[.ColumnSeparator]![section]
        }
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return cellLayoutAttributes[indexPath.section][indexPath.item]
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return supplementaryViewLayoutAttributes[SupplementaryViewKind(rawValue: elementKind)!]![indexPath.section][indexPath.item]
    }
    
    override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return decorationViewLayoutAttributes[DecorationViewKind(rawValue: elementKind)!]![indexPath.section][indexPath.row]
    }
}

class GridLayoutSeparator: UICollectionReusableView {
    
    class func widthInTraitCollection(collection: UITraitCollection) -> CGFloat {
        return 1.0 / (collection.displayScale == 0.0 ? 1.0 : collection.displayScale)
    }
}

extension CGFloat {
    
    func integratedFloatInTraitCollection(collection: UITraitCollection) -> CGFloat {
        return round(self * collection.displayScale) / collection.displayScale
    }
}

extension CGRect {
    
    func integratedRectInTraitCollection(collection: UITraitCollection) -> CGRect {
        
        let minX = self.minX.integratedFloatInTraitCollection(collection)
        let maxX = self.maxX.integratedFloatInTraitCollection(collection)
        let minY = self.minY.integratedFloatInTraitCollection(collection)
        let maxY = self.maxY.integratedFloatInTraitCollection(collection)
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}
