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

class GridLayoutAttributes: UICollectionViewLayoutAttributes {
    
    // Set to true if an element is pinned to the top of the view
    var pinned = false
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
    
    // MARK: Class overrides
    
    override class func layoutAttributesClass() -> AnyClass {
        return GridLayoutAttributes.self
    }
    
    // MARK: Initialization
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        registerNib(UINib(nibName: "GridLayoutColumnSeparator", bundle: nil), forDecorationViewOfKind: DecorationViewKind.ColumnSeparator.rawValue)
        registerNib(UINib(nibName: "GridLayoutRowSeparator", bundle: nil), forDecorationViewOfKind: DecorationViewKind.RowSeparator.rawValue)
    }
    
    // MARK: Delegate
    
    private var delegate: GridLayoutDelegate? {
        return collectionView?.delegate as? GridLayoutDelegate
    }
    
    // MARK: Properties
    
    @IBInspectable var minimumItemSideLength: CGFloat = 50.0 {
        didSet {
            invalidateLayout()
        }
    }
    
    @IBInspectable var headerHeight: CGFloat = 22.0 {
        didSet {
            invalidateLayout()
        }
    }
    
    @IBInspectable var showsSeparators = false
    
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
    private var decorationViewLayoutAttributes: [DecorationViewKind: [[UICollectionViewLayoutAttributes]]] = [:]
    
    // MARK: Layout
    
    override func prepareLayout() {
        
        minimumItemSideLengthsBySection = sectionRange().map { section in
            return self.delegate!.collectionView?(self.collectionView!, layout: self, minimumItemSideLengthForSection: section) ?? self.minimumItemSideLength
        }
        
        let contentWidth = collectionView!.bounds.width
        
        separatorWidth = showsSeparators ? Geometry.hairlineWidthInTraitCollection(collectionView!.traitCollection) : 0.0
        
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
                
                let layoutAttributes = GridLayoutAttributes(forCellWithIndexPath: indexPath)
                
                let column = item % numberOfColumns
                let row = item / numberOfColumns
                
                let rect = CGRect(x: CGFloat(column) * (itemSideLength * self.separatorWidth), y: sectionOffset + self.headerHeight + CGFloat(row) * (itemSideLength + self.separatorWidth), width: itemSideLength, height: itemSideLength)
                
                layoutAttributes.frame = rect.integratedRectInTraitCollection(self.collectionView!.traitCollection)
                
                return layoutAttributes
            }
        }
        
        if showsSeparators {
            
            decorationViewLayoutAttributes[.ColumnSeparator] = sectionRange().map { section in
                
                let numberOfColumns = self.numberOfColumnsBySection[section]
                let itemSideLength = self.itemSideLengthsBySection[section]
                let sectionOffset = self.heightForSections(0..<section)
                let height = self.heightForSection(section) - self.headerHeight
                
                let range = 0..<(numberOfColumns - 1)
                
                return range.map { item in
                    
                    let indexPath = NSIndexPath(forItem: item, inSection: section)
                    
                    let layoutAttributes = GridLayoutAttributes(forDecorationViewOfKind: DecorationViewKind.ColumnSeparator.rawValue, withIndexPath: indexPath)
                    
                    let rect = CGRect(x: itemSideLength + CGFloat(item) * (self.separatorWidth + itemSideLength), y: sectionOffset + self.headerHeight, width: self.separatorWidth, height: height)
                    
                    layoutAttributes.frame = rect.integratedRectInTraitCollection(self.collectionView!.traitCollection)
                    
                    return layoutAttributes
                }
            }
            
            decorationViewLayoutAttributes[.RowSeparator] = sectionRange().map { section in
                
                let numberOfRows = self.numberOfRowsBySection[section]
                let itemSideLength = self.itemSideLengthsBySection[section]
                let sectionOffset = self.heightForSections(0..<section)
                
                let isLastSection = section == self.sectionRange().endIndex - 1
                let range = 0..<(numberOfRows - (isLastSection ? 0 : 1))
                
                return range.map { item in
                    
                    let indexPath = NSIndexPath(forItem: item, inSection: section)
                    
                    let layoutAttributes = GridLayoutAttributes(forDecorationViewOfKind: DecorationViewKind.RowSeparator.rawValue, withIndexPath: indexPath)
                    
                    let rect = CGRect(x: 0.0, y: sectionOffset + self.headerHeight + itemSideLength + CGFloat(item) * (self.separatorWidth + itemSideLength), width: contentWidth, height: self.separatorWidth)
                    
                    layoutAttributes.frame = rect.integratedRectInTraitCollection(self.collectionView!.traitCollection)
                    
                    return layoutAttributes
                }
            }
            
        } else {
            
            decorationViewLayoutAttributes[.ColumnSeparator] = []
            decorationViewLayoutAttributes[.RowSeparator] = []
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        
        // The Swift compiler doesn't like this implementation from some reason and hangs on it
        
        /*
        return reduce(sectionRange(), [UICollectionViewLayoutAttributes]()) { layoutAttributes, section in
            return layoutAttributes + self.cellLayoutAttributes[section] + self.supplementaryViewLayoutAttributes[.Header]![section] + self.decorationViewLayoutAttributes[.ColumnSeparator]![section] + self.decorationViewLayoutAttributes[.RowSeparator]![section]
        }
        */
        
        // This implementation compiles just fine
        
        return reduce(sectionRange(), [UICollectionViewLayoutAttributes]()) { layoutAttributes, section in
            
            var attributes = layoutAttributes
            
            attributes += self.cellLayoutAttributes[section]
            
            if self.showsSeparators {
                attributes += self.decorationViewLayoutAttributes[.ColumnSeparator]![section]
                attributes += self.decorationViewLayoutAttributes[.RowSeparator]![section]
            }
            
            let headerLayoutAttributes = self.layoutAttributesForSupplementaryViewOfKind(SupplementaryViewKind.Header.rawValue, atIndexPath: NSIndexPath(forItem: 0, inSection: section))!
            
            attributes += [headerLayoutAttributes]
            
            return attributes
        }
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return cellLayoutAttributes[indexPath.section][indexPath.item]
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        
        let layoutAttributes = GridLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
        
        let sectionOffset = heightForSections(0..<indexPath.section)
        
        switch SupplementaryViewKind(rawValue: elementKind)! {
            
        case .Header:
            
            let top = collectionView!.contentInset.top + collectionView!.bounds.minY
            let sectionOffset = heightForSections(0..<indexPath.section)
            let nextSectionOffset = sectionOffset + heightForSection(indexPath.section)
            
            let headerOffset = min(max(top, sectionOffset), nextSectionOffset - headerHeight)
            
            let rect = CGRect(x: 0.0, y: headerOffset, width: contentSize.width, height: headerHeight)
            
            layoutAttributes.frame = rect.integratedRectInTraitCollection(self.collectionView!.traitCollection)
            
            layoutAttributes.zIndex = 1
            
            layoutAttributes.pinned = rect.minY > sectionOffset
        }
        
        return layoutAttributes
    }
    
    override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return decorationViewLayoutAttributes[DecorationViewKind(rawValue: elementKind)!]![indexPath.section][indexPath.row]
    }
    
    // MARK: Invalidation
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func invalidationContextForBoundsChange(newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        
        let context = super.invalidationContextForBoundsChange(newBounds)
        
        let headerIndexPaths: [NSIndexPath] = sectionRange().map { section in
            return NSIndexPath(forItem: 0, inSection: section)
        }
        
        context.invalidateSupplementaryElementsOfKind(SupplementaryViewKind.Header.rawValue, atIndexPaths: headerIndexPaths)
        
        return context
    }
}
