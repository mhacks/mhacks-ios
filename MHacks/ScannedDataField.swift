//
//  ScannedDataField.swift
//  MHacks
//
//  Created by Manav Gabhawala on 9/28/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import Foundation
import UIKit

struct ScannedDataField: SerializableElement
{
	var label: String
	var value: String
	var color: UIColor
}
extension ScannedDataField
{
	private static let valueKey = "value"
	private static let labelKey = "label"
	private static let colorKey = "color"
	
	init?(_ serializedRepresentation: SerializedRepresentation) {
		guard let value = serializedRepresentation[ScannedDataField.valueKey] as? String, let label = serializedRepresentation[ScannedDataField.labelKey] as? String
        else { return nil }
		var color = UIColor.black
		if let colorString = serializedRepresentation[ScannedDataField.colorKey] as? String, let hexValue = Int(colorString, radix: 16)
		{
			let red = CGFloat((hexValue >> 16) & 0xFF) / 255.0
			let green = CGFloat((hexValue >> 8) & 0xFF) / 255.0
			let blue = CGFloat(hexValue & 0xFF) / 255.0
			color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
		}
		
		self.init(label: label, value: value, color: color)
	}
	func toSerializedRepresentation() -> NSDictionary
	{
		return [:]
	}
}
