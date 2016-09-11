//
//  MHacksArray.swift
//  MHacks
//
//  Created by Manav Gabhawala on 9/4/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import Foundation

private let resultsKey = "results"

final class MHacksArray<Element>: Serializable, RandomAccessCollection where Element: SerializableElement, Element: Comparable
{
	private var items = [String: Element]()
	private var sortedKeys = [String]()
	private(set) var lastUpdated: Int?
	
	let semaphoreGuard = DispatchSemaphore(value: 1)
	let coalescer = CoalescedCallbacks()

	func updateWith(_ serializedRepresentation: SerializedRepresentation) -> Bool
	{
		guard let newItems = serializedRepresentation[resultsKey] as? [String: Any], let updatedAt = serializedRepresentation[MHacksArray.lastUpdatedKey] as? Int
		else {
			return false
		}
		lastUpdated = updatedAt
		
		// We keep the changes to the time regardless, if newItems.count == 0
		// we know nothing has changed, so we say nothing was updated
		guard newItems.count > 0
		else { return false }
		
		newItems.forEach {
			items[$0.0] = Element($0.1 as? [String: Any])
		}
		
		updateSortedKeys()
		
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
	convenience init?(_ serializedRepresentation : SerializedRepresentation)
	{
		self.init()
		_ = updateWith(serializedRepresentation)
	}
	
	func toSerializedRepresentation() -> NSDictionary
	{
		guard let lastUpdated = lastUpdated
			else { return NSDictionary() }
		
		return [MHacksArray.lastUpdatedKey: lastUpdated, resultsKey: items.map { $0.1.toSerializedRepresentation() } as NSArray]
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
