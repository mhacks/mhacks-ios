//
//  Extensions.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/18/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import Foundation
import UIKit

// This file is to make Foundation more Swifty

extension String {
	public var sentenceCapitalizedString : String
	{
		var formatted = ""
		enumerateSubstrings(in: startIndex..<endIndex, options: NSString.EnumerationOptions.bySentences, { sentence, sentenceRange, enclosingRange, stop in
			guard let sentence = sentence
			else
			{
				return
			}
			formatted += sentence.replacingCharacters(in: self.startIndex..<self.characters.index(self.startIndex, offsetBy: 1), with: sentence.substring(to: sentence.characters.index(after: sentence.startIndex)).capitalized)
		})
		// Add trailing full stop.
		if (formatted[formatted.index(before: formatted.endIndex)] != ".")
		{
			formatted += "."
		}
		return formatted
	}
}

let groupName = "group.com.MPowered.MHacks"
let defaults = UserDefaults(suiteName: groupName)!
let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName)!.appendingPathComponent("Library", isDirectory: true).appendingPathComponent("Application Support", isDirectory: true)

let cacheContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName)!.appendingPathComponent("Library", isDirectory: true).appendingPathComponent("Caches", isDirectory: true)

// MARK: - Keys for User Defaults

let remoteNotificationTokenKey = "remote_notification_token"
let remoteNotificationPreferencesKey = "remote_notification_preferences"

// MARK: - Color constants

extension UIColor
{
	static var mhacksBlue: UIColor
	{
		return UIColor(red: 0.0 / 255.0, green: 188.0 / 255.0, blue: 212.0 / 255.0, alpha: 1.0)
	}
	static var mhacksRed: UIColor
	{
		return UIColor.red
	}
	static var mhacksYellow: UIColor
	{
		return UIColor(red: 255.0 / 255.0, green: 202.0 / 255.0, blue: 11.0 / 255.0, alpha: 1.0)
	}
	static var mhacksOrange: UIColor
	{
		return UIColor(red: 247.0 / 255.0, green: 139.0 / 255.0, blue: 49.0 / 255.0, alpha: 1.0)
	}
	static var mhacksPurple: UIColor
	{
		return UIColor(red: 168.0 / 255.0, green: 110.0 / 255.0, blue: 219.0 / 255.0, alpha: 1.0)
	}
	static var mhacksPlain: UIColor
	{
		return UIColor.gray
	}
}

// MARK: Custom hit testing
extension UIView
{
	
	/// This beauty allows us to test whether a point in a view is actually transparent or not which means we can test for hit testing by what the user sees rather than the bounding box we would otherwise be restricted to
	///
	/// - Parameter point: The point in the view's space. This will get inverted during computation to convert to the view's bounds. Don't do any computation on the point you have, we do it here.
	/// - Returns: The alpha value for the view you call this function on with a bound of [0, 1.0] where 1.0 means maximum alpha.
	func alphaFromPoint(point: CGPoint) -> CGFloat {
		// Pixel information for point
		var pixel: [UInt8] = [0, 0, 0, 0]
		
		// Create an offscreen context to draw into so that we can fetch the pixel's information
		guard let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue)
		else {
			assertionFailure("Context should always be initializable. We return an alpha value in production builds instead of asserting")
			return 1.0
		}
		// Translation into context's space
		context.translateBy(x: -point.x, y: -point.y);
		
		// Render the view into the context so that the pixel's data gets filled
		layer.render(in: context)
		
		// Now the alpha is the last component inside pixel, the rest are rgb as you probably guessed.
		// Also, normalize alpha by dividing by 255.0
		return CGFloat(pixel[3]) / 255.0
	}
}
