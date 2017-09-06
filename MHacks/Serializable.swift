//
//  Serializable.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import Foundation

typealias SerializedRepresentation = [String: Any]
protocol SerializableElement
{
	init?(_ serializedRepresentation : SerializedRepresentation)
	func toSerializedRepresentation() -> NSDictionary
}
extension SerializableElement
{
	init?(_ serializedRepresentation : SerializedRepresentation?)
	{
		guard let serializedRepresentation = serializedRepresentation
			else { return nil }
		self.init(serializedRepresentation)
	}
}

protocol SerializableElementWithIdentifier: SerializableElement, Comparable, Hashable
{
	var ID: String { get }
	static var resultsKey: String { get }
}
extension SerializableElementWithIdentifier
{
	var hashValue: Int { return ID.hashValue }
	static var idKey: String { return "id" }
}
func ==<Type: SerializableElementWithIdentifier>(lhs: Type, rhs: Type) -> Bool
{
	return lhs.ID == rhs.ID
}
func < <Type: SerializableElementWithIdentifier>(lhs: Type, rhs: Type) -> Bool
{
	return lhs.ID < rhs.ID
}

protocol Serializable: class, SerializableElement
{
	func updateWith(_ serialized: SerializedRepresentation) -> Bool

	var semaphoreGuard: DispatchSemaphore { get }
	var coalescer: CoalescedCallbacks { get }
	var lastUpdated: Int? { get }
}
extension Serializable
{
	static var lastUpdatedKey: String { return "date_updated" }
	var sinceDictionary: [String: Any] {
		guard let lastUpdated = lastUpdated
			else { return [:] }
		return ["since": lastUpdated]
	}
}
