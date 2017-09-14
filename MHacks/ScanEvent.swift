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
    static var resultsKey: String = "scans"
	var name: String
	var expiryDate: Date
}
extension ScanEvent
{
	private static let nameKey = "name"
	private static let expiryDateKey = "expiry_date"
	
	init?(_ serializedRepresentation: SerializedRepresentation)
	{
		guard let ID = serializedRepresentation[ScanEvent.idKey] as? String, let name = serializedRepresentation[ScanEvent.nameKey] as? String
			else { return nil }
        let expiryDate: Date
        if let expiryDateRaw = serializedRepresentation[ScanEvent.expiryDateKey] as? Double
        {
            expiryDate = Date(timeIntervalSince1970: expiryDateRaw)
        }
        else
        {
            expiryDate = Date.distantFuture
        }
		self.init(ID: ID, name: name, expiryDate: expiryDate)
	}
	func toSerializedRepresentation() -> NSDictionary {
		return [ScanEvent.idKey: ID, ScanEvent.nameKey: name, ScanEvent.expiryDateKey: expiryDate.timeIntervalSince1970]
	}
}
func <(lhs: ScanEvent, rhs: ScanEvent) -> Bool
{
    return lhs.expiryDate < rhs.expiryDate
}
