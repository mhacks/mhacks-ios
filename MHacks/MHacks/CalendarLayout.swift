//
//  CalendarLayout.swift
//  MHacks
//
//  Created by Russell Ladd on 10/8/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

@objc protocol CalendarLayoutDelegate: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, numberOfRowsInSection section: Int) -> Int
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, startRowForItemAtIndexPath indexPath: NSIndexPath) -> Double
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, endRowForItemAtIndexPath indexPath: NSIndexPath) -> Double
}

class CalendarLayout: UICollectionViewLayout {
    
    // MARK: Constants
    
    enum SupplementaryViewKind: String {
        case Header = "Header"
        case Separator = "Separator"
    }
    
    // MARK: Delegate
    
    private var delegate: CalendarLayoutDelegate? {
        return collectionView?.delegate as? CalendarLayoutDelegate
    }
    
    // MARK: Layout metrics
    
    var rowHeight = CGFloat(44.0)
    
    var headerHeight = CGFloat(33.0)
    var separatorHeight = CGFloat(22.0)
    
    // MARK: Layout calculations
    
    private func heightForSection(section: Int) -> CGFloat {
        return headerHeight + CGFloat(numberOfRowsBySection[section]) * rowHeight
    }
    
    private func heightForSections(sections: Range<Int>) -> CGFloat {
        return reduce(sections, 0.0) { offset, section in
            return offset + self.heightForSection(section)
        }
    }
    
    // MARK: Cache
    
    func sectionRange() -> Range<Int> {
        return 0..<collectionView!.numberOfSections()
    }
    
    func itemRangeForSection(section: Int) -> Range<Int> {
        return 0..<collectionView!.numberOfItemsInSection(section)
    }
    
    var numberOfRowsBySection = [Int]()
    
    var contentSize = CGSizeZero
    
    var cellLayoutAttributes = [[UICollectionViewLayoutAttributes]]()
    
    // MARK: Layout
    
    override func prepareLayout() {
        
        numberOfRowsBySection = map(sectionRange()) { section in
            return self.delegate!.collectionView(self.collectionView!, layout: self, numberOfRowsInSection: section)
        }
        
        contentSize = CGSizeMake(collectionView!.bounds.size.width, heightForSections(sectionRange()))
        
        cellLayoutAttributes = map(sectionRange()) { section in
            return map(self.itemRangeForSection(section)) { item in
                
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                
                let layoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                
                let startRow = self.delegate!.collectionView(self.collectionView!, layout: self, startRowForItemAtIndexPath: indexPath)
                let endRow = self.delegate!.collectionView(self.collectionView!, layout: self, endRowForItemAtIndexPath: indexPath)
                
                let sectionOffset = self.heightForSections(0..<section) + self.headerHeight
                
                let startOffset = sectionOffset + CGFloat(startRow) * self.rowHeight
                let endOffset = sectionOffset + CGFloat(endRow) * self.rowHeight
                
                layoutAttributes.frame = CGRectMake(0.0, startOffset, self.contentSize.width, endOffset - startOffset)
                
                return layoutAttributes
            }
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        return contentSize
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        
        return reduce(sectionRange(), [UICollectionViewLayoutAttributes]()) { layoutAttributes, section in
            
            let headerLayoutAttributes = self.layoutAttributesForSupplementaryViewOfKind(SupplementaryViewKind.Header.rawValue, atIndexPath: NSIndexPath(forItem: 0, inSection: section))!
            
            let separatorLayoutAttributes: [UICollectionViewLayoutAttributes] = map(1..<self.numberOfRowsBySection[section]) { row in
                return self.layoutAttributesForSupplementaryViewOfKind(SupplementaryViewKind.Separator.rawValue, atIndexPath: NSIndexPath(forItem: row, inSection: section))
            }
            
            let cellLayoutAttributes: [UICollectionViewLayoutAttributes] = map(self.itemRangeForSection(section)) { item in
                return self.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: item, inSection: section))
            }
            
            return layoutAttributes + [headerLayoutAttributes] + separatorLayoutAttributes + cellLayoutAttributes
        }
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return cellLayoutAttributes[indexPath.section][indexPath.item]
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        
        let layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
        
        let sectionOffset = heightForSections(0..<indexPath.section)
        
        switch SupplementaryViewKind(rawValue: elementKind)! {
            
        case .Header:
            let headerOffset = min(max(collectionView!.contentInset.top + collectionView!.bounds.origin.y, heightForSections(0..<indexPath.section)), heightForSections(0..<indexPath.section + 1) - headerHeight)
            layoutAttributes.frame = CGRectMake(0.0, headerOffset, contentSize.width, headerHeight)
            layoutAttributes.zIndex = 1
            
        case .Separator:
            layoutAttributes.frame = CGRectMake(0.0, sectionOffset + headerHeight + CGFloat(indexPath.item) * rowHeight - separatorHeight / 2.0, contentSize.width, separatorHeight)
            layoutAttributes.zIndex = -1
        }
        
        return layoutAttributes
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
