//
//  Countdown.swift
//  MHacks
//
//  Created by Russell Ladd on 11/12/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

final class Countdown : Serializable, Equatable {
	
	// MARK : - Properties
    private(set) var startDate: Date
    private(set) var duration: TimeInterval
	private(set) var hacksSubmittedBy: TimeInterval
	
	let semaphoreGuard = DispatchSemaphore(value: 1)
	let coalescer = CoalescedCallbacks()
	private(set) var lastUpdated: Int?

	
    var endDate: Date {
        return startDate.addingTimeInterval(duration)
    }
	var hacksSubmittedByDate: Date {
		return startDate.addingTimeInterval(hacksSubmittedBy)
	}
	
    var roundedCurrentDate: Date {
        return startDate.addingTimeInterval(duration - roundedTimeRemaining)
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
		
		let dateText = Countdown.dateFormatter.string(from: startDate)
		
		return String(format: message, dateText)
	}
	
	var endDateDescription: String {
		
		let message: String
			
		let currentDate = roundedCurrentDate
		var dateInText = endDate
		
		if currentDate < endDate
		{
			if currentDate < hacksSubmittedByDate && currentDate > startDate
			{
				message = NSLocalizedString("Hacks must be submitted by\n%@", comment: "Countdown hacks submitted by")
				dateInText = hacksSubmittedByDate
			}
			else
			{
				message = NSLocalizedString("Hacking finishes\n%@.", comment: "Countdown hacking will end")
			}
		}
		else
		{
			message = NSLocalizedString("Hacking finished\n%@.", comment: "Countdown hacking did end")
		}
		
		let dateText = Countdown.dateFormatter.string(from: dateInText)
		return String(format: message, dateText)
	}
	
	// The current date clipped to the start and end of the event
	
	func progressDate(for date: Date = Date()) -> Date {
		return min(max(date, startDate), endDate)
	}
	
	func timeRemaining(for date: Date = Date()) -> TimeInterval {
		return endDate.timeIntervalSince(progressDate(for: date))
	}
	
	var roundedTimeRemaining: TimeInterval {
		return round(timeRemaining())
	}
	
	var timeRemainingDescription: String {
		
		let total = Int(roundedTimeRemaining)
		
		let hours = Countdown.timeRemainingFormatter.string(for: total / 3600)!
		let minutes = Countdown.timeRemainingFormatter.string(for: (total % 3600) / 60)!
		let seconds = Countdown.timeRemainingFormatter.string(for: total % 60)!
		
		return "\(hours):\(minutes):\(seconds)"
	}
	
	static let font: UIFont = {
		// Use SF font with monospaced digit for iOS 9+
		return UIFont.monospacedDigitSystemFont(ofSize: 120.0, weight: UIFontWeightThin)
	}()
	
	func progress(for date: Date = Date()) -> Double {
		return 1.0 - timeRemaining(for: date) / duration
	}
	
	// MARK: - Helpers
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.formattingContext = .middleOfSentence
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
	
    private static var timeRemainingFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2
        return formatter
    }()
    
	private static let countdownStartDateKey = "start_time"
	private static let countdownDurationKey = "countdown_duration"
	private static let hacksSubmittedByDurationKey = "hacks_submitted"
	
	init(startDate: Date = Date(timeIntervalSince1970: 1475899200), duration: TimeInterval = 129600, hacksSubmittedBy: TimeInterval = 118800) {
        self.startDate = startDate
		self.duration = duration
		self.hacksSubmittedBy = hacksSubmittedBy
    }
	
	convenience init?(_ serializedRepresentation: SerializedRepresentation) {
		self.init()
		_ = updateWith(serializedRepresentation)
	}
	
	func toSerializedRepresentation() -> NSDictionary {
		return [Countdown.countdownStartDateKey: startDate.timeIntervalSince1970, Countdown.countdownDurationKey: duration, Countdown.hacksSubmittedByDurationKey: hacksSubmittedBy, Countdown.lastUpdatedKey: lastUpdated ?? 0]
	}
	
	func updateWith(_ serialized: SerializedRepresentation) -> Bool {
		guard let lastUpdated = serialized[Countdown.lastUpdatedKey] as? Int
		else {
			return false
		}
		self.lastUpdated = lastUpdated

		guard let startDateTimeStamp = serialized[Countdown.countdownStartDateKey] as? Double, let duration = serialized[Countdown.countdownDurationKey] as? Double, let hacksSubmittedBy = serialized[Countdown.hacksSubmittedByDurationKey] as? Double
		else {
			return false
		}
		
		self.startDate = Date(timeIntervalSince1970: startDateTimeStamp)
		self.duration = duration
		self.hacksSubmittedBy = hacksSubmittedBy
		
		return true
	}

}

func ==(lhs: Countdown, rhs: Countdown) -> Bool {
	return lhs.startDate == rhs.startDate && lhs.duration == rhs.duration && lhs.hacksSubmittedBy == rhs.hacksSubmittedBy
}
