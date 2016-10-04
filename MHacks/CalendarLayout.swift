//
//  CalendarLayout.swift
//  MHacks
//
//  Created by Russell Ladd on 10/8/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

@objc protocol CalendarLayoutDelegate: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, numberOfRowsInSection section: Int) -> Int
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, startRowForItemAtIndexPath indexPath: IndexPath) -> Double
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, endRowForItemAtIndexPath indexPath: IndexPath) -> Double
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, numberOfColumnsForItemAtIndexPath indexPath: IndexPath) -> Int
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, columnForItemAtIndexPath indexPath: IndexPath) -> Int
}

class CalendarLayout: UICollectionViewLayout {
    
    // MARK: Constants
    
    enum SupplementaryViewKind: String {
        case Header = "Header"
        case Separator = "Separator"
		case NowIndicator = "NowIndicator"
		case NowLabel = "NowLabel"
    }
    
    // MARK: Delegate
    
    fileprivate var delegate: CalendarLayoutDelegate? {
        return collectionView?.delegate as? CalendarLayoutDelegate
    }
    
    // MARK: Layout metrics
    
    var rowHeight: CGFloat = 55.0 {
        didSet {
            invalidateLayout()
        }
    }
    
    var rowInsets: UIEdgeInsets = .zero {
        didSet {
            invalidateLayout()
        }
    }
    
    var cellInsets: UIEdgeInsets = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0) {
        didSet {
            invalidateLayout()
        }
    }
    
    var headerHeight: CGFloat = 33.0 {
        didSet {
            invalidateLayout()
        }
    }
    
    var separatorHeight: CGFloat = 22.0 {
        didSet {
            invalidateLayout()
        }
    }
	
	var nowIndicatorPosition: (section: Int, row: Double)? = nil {
		didSet {
			invalidateLayout()
		}
	}
	
    // MARK: Layout calculations
    
    private func heightForSection(_ section: Int) -> CGFloat {
        return headerHeight + CGFloat(numberOfRowsBySection[section]) * rowHeight
    }
    
    private func heightForSections(_ sections: CountableRange<Int>) -> CGFloat {
        return sections.reduce(0.0) { offset, section in
            return offset + self.heightForSection(section)
        }
    }
    
    // MARK: Cache
    
    func sectionRange() -> CountableRange<Int> {
        return 0..<collectionView!.numberOfSections
    }
    
    func itemRangeForSection(_ section: Int) -> CountableRange<Int> {
        return 0..<collectionView!.numberOfItems(inSection: section)
    }
    
    var numberOfRowsBySection = [Int]()
    
    var contentSize = CGSize.zero
    
    var cellLayoutAttributes = [[UICollectionViewLayoutAttributes]]()
    
    // MARK: Layout
    
    override func prepare() {
        
        numberOfRowsBySection = sectionRange().map { section in
            return self.delegate!.collectionView(self.collectionView!, layout: self, numberOfRowsInSection: section)
        }
        
        contentSize = CGSize(width: collectionView!.bounds.size.width, height: heightForSections(sectionRange()))
        
        cellLayoutAttributes = sectionRange().map { section in
            return self.itemRangeForSection(section).map { item in
                
                let indexPath = IndexPath(item: item, section: section)
                
                let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                let startRow = self.delegate!.collectionView(self.collectionView!, layout: self, startRowForItemAtIndexPath: indexPath)
                let endRow = self.delegate!.collectionView(self.collectionView!, layout: self, endRowForItemAtIndexPath: indexPath)
                
                let sectionOffset = self.heightForSections(0..<section) + self.headerHeight
                
                let startOffset = sectionOffset + CGFloat(startRow) * self.rowHeight
                let endOffset = sectionOffset + CGFloat(endRow) * self.rowHeight
                
                let rect = CGRect(x: 0.0, y: startOffset, width: self.contentSize.width, height: endOffset - startOffset)
                
                let rowRect = UIEdgeInsetsInsetRect(rect, self.rowInsets)
                
                let numberOfColumns = self.delegate!.collectionView(self.collectionView!, layout: self, numberOfColumnsForItemAtIndexPath: indexPath)
                let column = self.delegate!.collectionView(self.collectionView!, layout: self, columnForItemAtIndexPath: indexPath)
                
                let columnWidth = rowRect.width / CGFloat(numberOfColumns)
                
                let columnRect = CGRect(x: rowRect.minX + CGFloat(column) * columnWidth, y: rowRect.minY, width: columnWidth, height: rowRect.height)
                
                let cellRect = UIEdgeInsetsInsetRect(columnRect, self.cellInsets)
                
                layoutAttributes.frame = cellRect.integratedRectInTraitCollection(self.collectionView!.traitCollection)
                layoutAttributes.zIndex = indexPath.item
                
                return layoutAttributes
            }
        }
    }
	
	override var collectionViewContentSize: CGSize {
		return contentSize
	}
	
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
		var layoutAttributes = sectionRange().reduce([UICollectionViewLayoutAttributes]()) { layoutAttributes, section in
            
            let headerLayoutAttributes = [self.layoutAttributesForSupplementaryView(ofKind: SupplementaryViewKind.Header.rawValue, at: IndexPath(item: 0, section: section))!]
            
            let separatorLayoutAttributes: [UICollectionViewLayoutAttributes] = (1..<self.numberOfRowsBySection[section]).map { row in
                return self.layoutAttributesForSupplementaryView(ofKind: SupplementaryViewKind.Separator.rawValue, at: IndexPath(item: row, section: section))!
            }
            
            let cellLayoutAttributes: [UICollectionViewLayoutAttributes] = self.itemRangeForSection(section).map { item in
                return self.layoutAttributesForItem(at: IndexPath(item: item, section: section))!
            }
            
            return layoutAttributes + headerLayoutAttributes + separatorLayoutAttributes + cellLayoutAttributes
        }
		
		if nowIndicatorPosition != nil {
			layoutAttributes += [layoutAttributesForSupplementaryView(ofKind: SupplementaryViewKind.NowIndicator.rawValue, at: IndexPath(item: 0, section: 0))!, layoutAttributesForSupplementaryView(ofKind: SupplementaryViewKind.NowLabel.rawValue, at: IndexPath(item: 0, section: 0))!]
		}
		
		return layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cellLayoutAttributes[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).item]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        
        let sectionOffset = heightForSections(0..<(indexPath as NSIndexPath).section)
        
        switch SupplementaryViewKind(rawValue: elementKind)! {
            
        case .Header:
            let headerOffset = min(max(collectionView!.contentInset.top + collectionView!.bounds.origin.y, heightForSections(0..<(indexPath as NSIndexPath).section)), heightForSections(0..<(indexPath as NSIndexPath).section + 1) - headerHeight)
            layoutAttributes.frame = CGRect(x: 0.0, y: headerOffset, width: contentSize.width, height: headerHeight)
            layoutAttributes.zIndex = Int.max - 3
            
        case .Separator:
            layoutAttributes.frame = CGRect(x: 0.0, y: sectionOffset + headerHeight + CGFloat((indexPath as NSIndexPath).item) * rowHeight - separatorHeight / 2.0, width: contentSize.width, height: separatorHeight)
            layoutAttributes.zIndex = -1
			
		case .NowIndicator:
			
			guard let nowIndicatorPosition = nowIndicatorPosition else {
				layoutAttributes.isHidden = true
				break
			}
			
			let sectionOffset = heightForSections(0..<nowIndicatorPosition.section)
			
			layoutAttributes.frame = CGRect(x: 0.0, y: sectionOffset + headerHeight + CGFloat(nowIndicatorPosition.row) * rowHeight - separatorHeight / 2.0, width: contentSize.width, height: separatorHeight)
			layoutAttributes.zIndex = Int.max - 2
			
		case .NowLabel:
			
			guard let nowIndicatorPosition = nowIndicatorPosition else {
				return nil
			}
			
			let sectionOffset = heightForSections(0..<nowIndicatorPosition.section)
			
			layoutAttributes.frame = CGRect(x: 0.0, y: sectionOffset + headerHeight + CGFloat(nowIndicatorPosition.row) * rowHeight - separatorHeight / 2.0, width: contentSize.width, height: separatorHeight)
			layoutAttributes.zIndex = Int.max - 1

        }
		
        return layoutAttributes
    }
    
    // MARK: Invalidation
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        
        let context = super.invalidationContext(forBoundsChange: newBounds)
        
        let headerIndexPaths: [IndexPath] = sectionRange().map { section in
            return IndexPath(item: 0, section: section)
        }
        
        context.invalidateSupplementaryElements(ofKind: SupplementaryViewKind.Header.rawValue, at: headerIndexPaths)
        
        return context
    }
}
