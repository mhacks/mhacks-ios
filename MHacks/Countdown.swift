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
				return NSLocalizedString("Hacking started on\n%@.", comment: "Countdown hacking did start")
			}
			else
			{
				return NSLocalizedString("Hacking starts on\n%@.", comment: "Countdown hacking will start")
			}
		}()
		
		let dateText = Countdown.dateFormatter.stringFromDate(startDate)
		
		return String(format: message, dateText)
	}
	
	var endDateDescription: String {
		
		let message: String = {
			
			if self.roundedCurrentDate < self.endDate
			{
				return NSLocalizedString("Hacking finishes on\n%@.", comment: "Countdown hacking will end")
			}
			else
			{
				return NSLocalizedString("Hacking finished on\n%@.", comment: "Countdown hacking did end")
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
		// Use SF font with monospaced digit for iOS 9+
		return UIFont.monospacedDigitSystemFontOfSize(120.0, weight: UIFontWeightThin)
	}()
	
	var progress: Double {
		return 1.0 - timeRemaining / duration
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
    
	private static let countdownStartDateKey = "start_time"
	private static let countdownDurationKey = "countdown_duration"
	
	init(startDate: NSDate = NSDate(timeIntervalSince1970: 1455944400), duration: NSTimeInterval = 129600000) {
        self.startDate = startDate
		self.duration = duration / 1000.0
    }
	
	convenience init?(serialized: Serialized)
	{
		guard let startDateTimeStamp = serialized.doubleValueForKey(Countdown.countdownStartDateKey), let duration = serialized.doubleValueForKey(Countdown.countdownDurationKey)
		else
		{
			return nil
		}
		self.init(startDate: NSDate(timeIntervalSince1970: startDateTimeStamp), duration: duration)
	}
}

// MARK: - NSCoding
extension Countdown : JSONCreateable, NSCoding
{
	@objc func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encode(startDate.timeIntervalSince1970, forKey: Countdown.countdownStartDateKey)
		aCoder.encode(duration, forKey: Countdown.countdownDurationKey)
	}
	@objc convenience init?(coder aDecoder: NSCoder) {
		self.init(serialized: Serialized(coder: aDecoder))
	}
}

func ==(lhs: Countdown, rhs: Countdown) -> Bool {
	return lhs.startDate == rhs.startDate && lhs.duration == rhs.duration
}
