//
//  Countdown.swift
//  MHacks
//
//  Created by Russell Ladd on 11/12/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

struct Countdown {
    
    let startDate: NSDate?
    let duration: NSTimeInterval
    
    var endDate: NSDate? {
        return startDate?.dateByAddingTimeInterval(duration)
    }
    
    var roundedCurrentDate: NSDate? {
        return startDate?.dateByAddingTimeInterval(duration - roundedTimeRemaining)
    }
    
    private static var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.formattingContext = .MiddleOfSentence
        formatter.dateStyle = .FullStyle
        formatter.timeStyle = .ShortStyle
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
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
        
        let dateText = startDate != nil ? Countdown.dateFormatter.stringFromDate(startDate!) : "…"
        
        return NSString(format: message, dateText) as String
    }
    
    var endDateDescription: String {
        
        let message: String = {
			
			if self.roundedCurrentDate <= self.startDate
			{
				return NSLocalizedString("Hacks must be submitted by\n%@.", comment: "Countdown hacking will end")
			}
			else
			{
				return NSLocalizedString("Hacks were submitted\n%@.", comment: "Countdown hacking did end")
			}
        }()
        
        let dateText = endDate != nil ? Countdown.dateFormatter.stringFromDate(endDate!) : "…"
        
        return NSString(format: message, dateText) as String
    }
    
    // The current date clipped to the start and end of the event
    var progressDate: NSDate {
        return NSDate().laterDate(startDate!).earlierDate(endDate!);
    }
    
    var timeRemaining: NSTimeInterval {
        return endDate?.timeIntervalSinceDate(progressDate) ?? duration
    }
    
    var roundedTimeRemaining: NSTimeInterval {
        return round(timeRemaining)
    }
    
    private static var timeRemainingFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.minimumIntegerDigits = 2
        return formatter
    }()
    
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
        return 1.0 - timeRemaining / duration
    }
    
	init(startDate: NSDate? = nil, duration: NSTimeInterval = 129600) {
		// TODO: Create from cache instead of from default values
        self.startDate = startDate
        self.duration = duration
    }
}
extension Countdown : JSONCreateable
{
	init?(JSON: [String: AnyObject])
	{
		guard let startDate = JSON["countdown_start_date"] as? NSTimeInterval, let duration = JSON["countdown_duration"] as? NSTimeInterval
		else
		{
			return nil
		}
		// Make sure that the startDate from server is EPOCH time or UNIX time
		self.startDate = NSDate(timeIntervalSince1970: startDate)
		self.duration = duration
	}
	
	func encodeWithCoder(aCoder: NSCoder){
		// TODO: Implement me
	}
	static var jsonKeys : [String] { return ["countdown_start_date", "countdown_duration"] }

}

