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

// FIXME: Is this lock still necessary? It used to crash without it in earlier versions
private let calendarLock = NSLock()
extension Calendar {
	static var shared: Calendar {
		calendarLock.lock()
		defer { calendarLock.unlock() }
		return Calendar.current

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
		return UIColor(red: 0.0, green: 188.0 / 255.0, blue: 212.0 / 255.0, alpha: 1.0)
	}
	static var mhacksRed: UIColor
	{
			return UIColor.red
	}
	static var mhacksYellow: UIColor
	{
		return UIColor.yellow
	}
	static var mhacksOrange: UIColor
	{
		return UIColor.orange
	}
	static var mhacksPurple: UIColor
	{
		return UIColor.purple
	}
	static var mhacksPlain: UIColor
	{
		return UIColor.gray
	}
}
