//
//  ScanEvent.swift
//  MHacks
//
//  Created by Manav Gabhawala on 9/20/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import Foundation

struct ScanEvent: SerializableElementWithIdentifier
{
	var ID: String
	var name: String
	var expiryDate: Date
}
extension ScanEvent
{
	private static let nameKey = "name"
	private static let expiryDateKey = "expiry_date"
	
	init?(_ serializedRepresentation: SerializedRepresentation)
	{
		guard let ID = serializedRepresentation[ScanEvent.idKey] as? String, let name = serializedRepresentation[ScanEvent.nameKey] as? String, let expiryDateRaw = serializedRepresentation[ScanEvent.expiryDateKey] as? Double
			else { return nil }
		self.init(ID: ID, name: name, expiryDate: Date(timeIntervalSince1970: expiryDateRaw))
	}
	func toSerializedRepresentation() -> NSDictionary {
		return [ScanEvent.idKey: ID, ScanEvent.nameKey: name, ScanEvent.expiryDateKey: expiryDate.timeIntervalSince1970]
	}
}
