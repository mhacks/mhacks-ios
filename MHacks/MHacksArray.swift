//
//  MHacksArray.swift
//  MHacks
//
//  Created by Manav Gabhawala on 9/4/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import Foundation

final class MHacksArray<Element>: Serializable, RandomAccessCollection where Element: SerializableElementWithIdentifier, Element: Comparable
{
	private var items = [String: Element]()
	private var sortedKeys = [String]()
	private(set) var lastUpdated: Int?
	
	let semaphoreGuard = DispatchSemaphore(value: 1)
	let coalescer = CoalescedCallbacks()

	func updateWith(_ serializedRepresentation: SerializedRepresentation) -> Bool
	{
		guard let newItems = serializedRepresentation[Element.resultsKey] as? [[String: Any]]
        else {
			return false
		}
        
        if let archivedLastUpdated = serializedRepresentation["date_updated"] as? Int {
            lastUpdated = archivedLastUpdated
        }
        
		// We keep the changes to the time regardless, if newItems.count == 0
		// we know nothing has changed, so we say nothing was updated
		guard newItems.count > 0
		else { return false }
		
		// We must sync on to the main queue for two reasons:
		//	- To avoid the UI asking us for updates while we are busy updating the array, if they do it will most definitely crash
		//  - It must be sync and not async because the APIManager expects true to be returned once everything is truly updated.
		DispatchQueue.main.sync {
            var maxLastUpdated = lastUpdated ?? 0
            
			newItems.forEach {
				guard let id = $0[Element.self.idKey] as? String else { return }
                if $0["deleted"] as? Bool == true {
                    self.items[id] = nil
                } else {
                    self.items[id] = Element($0)
                }
                
                if let elementLastUpdated = $0["updatedAt_ts"] as? Int {
                    maxLastUpdated = Swift.max(maxLastUpdated, elementLastUpdated)
                }
			}
            
            self.lastUpdated = maxLastUpdated + 1
			self.updateSortedKeys()
		}
		
		return true
	}
	
	private func updateSortedKeys()
	{
		sortedKeys = items.keys.sorted {
			let lhs = self.items[$0]!
			let rhs = self.items[$1]!
			return lhs < rhs
		}
	}
	subscript(index: Int) -> Element
	{
		return items[sortedKeys[index]]!
	}
	subscript(id: String) -> Element?
	{
		return items[id]
	}
	convenience init?(_ serializedRepresentation : SerializedRepresentation)
	{
		self.init()
		_ = updateWith(serializedRepresentation)
	}
	
	func toSerializedRepresentation() -> NSDictionary
	{
		guard let lastUpdated = lastUpdated
			else { return NSDictionary() }
		
		return [MHacksArray.lastUpdatedKey: lastUpdated, Element.resultsKey: items.map { $0.1.toSerializedRepresentation() } as NSArray]
	}
	
	
	/// Useful if you need to invalidate the cache, if privileges change for example
    /// It is not guaranteed that the cache will be invalidated immediately in order to maintain thread safety. 
    /// However it is guranteed that the cache will eventually be cleared and the function will return immediately.
	func invalidateElements() {
        DispatchQueue.global(qos: .utility).async {
            self.semaphoreGuard.wait()
            defer { self.semaphoreGuard.signal() }
            DispatchQueue.main.sync {
                self.items.removeAll(keepingCapacity: true)
                self.sortedKeys.removeAll(keepingCapacity: true)
                self.lastUpdated = nil
            }
        }
	}
	
	// MARK: - Stuff to make this "look" like a regular array
	typealias Index = Int
	typealias Indices = CountableRange<Int>

	var startIndex: Int { return 0 }
	var endIndex: Int { return items.count }
	
	func index(after i: Int) -> Int {
		return i + 1
	}
	func index(before i: Int) -> Int {
		return i - 1
	}
	func index(_ i: Int, offsetBy n: Int) -> Int {
		return i + n
	}
}
