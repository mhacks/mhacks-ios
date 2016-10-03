//
//  Extensions.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/18/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import Foundation

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
