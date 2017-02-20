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
struct MHacksColor
{
	static var blue: UIColor
	{
		return UIColor(red: 0.0 / 255.0, green: 188.0 / 255.0, blue: 212.0 / 255.0, alpha: 1.0)
	}
	static var red: UIColor
	{
		return UIColor.red
	}
	static var yellow: UIColor
	{
		return UIColor(red: 255.0 / 255.0, green: 202.0 / 255.0, blue: 11.0 / 255.0, alpha: 1.0)
	}
	static var orange: UIColor
	{
		return UIColor(red: 241.0 / 255.0, green: 103.0 / 255.0, blue: 88.0 / 255.0, alpha: 1.0)
	}
	static var purple: UIColor
	{
		return UIColor(red: 168.0 / 255.0, green: 110.0 / 255.0, blue: 219.0 / 255.0, alpha: 1.0)
	}
	static var plain: UIColor
	{
		#if os(watchOS)
		return UIColor.white
		#else
		return UIColor.gray
		#endif
	}
}

