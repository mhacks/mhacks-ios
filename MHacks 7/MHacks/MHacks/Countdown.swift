//
//  Countdown.swift
//  MHacks
//
//  Created by Russell Ladd on 11/12/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

@objc final class Countdown : NSObject {
	
	// MARK : - Properties
    let startDate: NSDate
    let duration: NSTimeInterval
	
    var endDate: NSDate {
        return startDate.dateByAddingTimeInterval(duration)
    }
    
    var roundedCurrentDate: NSDate? {
        return startDate.dateByAddingTimeInterval(duration - roundedTimeRemaining)
    }
	
	var startDateDescription: String {
		
		let message: String = {
			if self.roundedCurrentDate > self.startDate
			{
				return NSLocalizedString("Hacking started\n%@.", comment: "Countdown hacking did start")
			}
			else
			{
				return NSLocalizedString("Hacking starts\n%@.", comment: "Countdown hacking will start")
			}
		}()
		
		let dateText = Countdown.dateFormatter.stringFromDate(startDate)
		
		return String(format: message, dateText)
	}
	
	var endDateDescription: String {
		
		let message: String = {
			
			if self.roundedCurrentDate <= self.endDate
			{
				return NSLocalizedString("Hacks must be submitted by\n%@.", comment: "Countdown hacking will end")
			}
			else
			{
				return NSLocalizedString("Hacks were submitted\n%@.", comment: "Countdown hacking did end")
			}
		}()
		
		let dateText = Countdown.dateFormatter.stringFromDate(endDate)
		
		return NSString(format: message, dateText) as String
	}
	
	// The current date clipped to the start and end of the event
	var progressDate: NSDate {
		return min(max(NSDate(), startDate), endDate)
	}
	
	var timeRemaining: NSTimeInterval {
		return endDate.timeIntervalSinceDate(progressDate)
	}
	
	var roundedTimeRemaining: NSTimeInterval {
		return round(timeRemaining)
	}
	
	var timeRemainingDescription: String {
		
		let total = Int(roundedTimeRemaining)
		
		let hours = Countdown.timeRemainingFormatter.stringFromNumber(total / 3600)!
		let minutes = Countdown.timeRemainingFormatter.stringFromNumber((total % 3600) / 60)!
		let seconds = Countdown.timeRemainingFormatter.stringFromNumber(total % 60)!
		
		return "\(hours):\(minutes):\(seconds)"
	}
	
	static let font: UIFont = {
		if #available(iOS 9.0, *) {
			// Use SF font with monospaced digit for iOS 9+
			return UIFont.monospacedDigitSystemFontOfSize(120.0, weight: UIFontWeightThin)
		} else {
			// Use helvetica neue for iOS 8.0
			let timeSeparatorValue = 1
			let featureSettings = [[UIFontFeatureTypeIdentifierKey: kCharacterAlternativesType, UIFontFeatureSelectorIdentifierKey: timeSeparatorValue]]
			let descriptor = UIFont(name: "HelveticaNeue-Thin", size: 120.0)!.fontDescriptor().fontDescriptorByAddingAttributes([UIFontDescriptorFeatureSettingsAttribute: featureSettings])
			return UIFont(descriptor: descriptor, size: 0.0)
		}
	}()
	
	var progress: Double {
		return timeRemaining / duration
	}
	
	// MARK: - Helpers
    private static var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.formattingContext = .MiddleOfSentence
        formatter.dateStyle = .FullStyle
        formatter.timeStyle = .ShortStyle
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
	
    private static var timeRemainingFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.minimumIntegerDigits = 2
        return formatter
    }()
    
	private static let countdownStartDateKey = "countdown_start_date"
	private static let countdownDurationKey = "countdown_duration"
	
	init(startDate: NSDate = NSDate(timeIntervalSinceReferenceDate: 477608400), duration: NSTimeInterval = 129600) {
        self.startDate = startDate
		self.duration = duration
    }
	
	convenience init?(serialized: Serialized)
	{
		guard let startDate = NSDate(JSONValue: serialized[Countdown.countdownStartDateKey]), let duration = serialized._JSON?[Countdown.countdownDurationKey] as? NSTimeInterval ?? serialized._coder?.decodeDoubleForKey(Countdown.countdownDurationKey)
		else
		{
			return nil
		}
		
		self.init(startDate: startDate, duration: duration)
	}
}

// MARK: - NSCoding
extension Countdown : JSONCreateable, NSCoding
{
	@objc func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(JSONDateFormatter.stringFromDate(startDate), forKey: Countdown.countdownStartDateKey)
		aCoder.encodeDouble(duration, forKey: Countdown.countdownDurationKey)
	}
	@objc convenience init?(coder aDecoder: NSCoder) {
		self.init(serialized: Serialized(coder: aDecoder))
	}
}

func ==(lhs: Countdown, rhs: Countdown) -> Bool {
	return lhs.startDate == rhs.startDate && lhs.duration == rhs.duration
}
