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
	
	let semaphoreGuard = DispatchSemaphore(value: 1)
	let coalescer = CoalescedCallbacks()
	private(set) var lastUpdated: Int?

	
    var endDate: Date {
        return startDate.addingTimeInterval(duration)
    }
    
    var roundedCurrentDate: Date {
        return startDate.addingTimeInterval(duration - roundedTimeRemaining)
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
		
		let dateText = Countdown.dateFormatter.string(from: startDate)
		
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
		
		let dateText = Countdown.dateFormatter.string(from: endDate)
		
		return NSString(format: message as NSString, dateText) as String
	}
	
	// The current date clipped to the start and end of the event
	var progressDate: Date {
		return min(max(Date(), startDate), endDate)
	}
	
	var timeRemaining: TimeInterval {
		return endDate.timeIntervalSince(progressDate)
	}
	
	var roundedTimeRemaining: TimeInterval {
		return round(timeRemaining)
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
	
	var progress: Double {
		return 1.0 - timeRemaining / duration
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
	
	init(startDate: Date = Date(timeIntervalSince1970: 1455944400), duration: TimeInterval = 129600000) {
        self.startDate = startDate
		self.duration = duration / 1000.0
    }
	
	convenience init?(_ serializedRepresentation: SerializedRepresentation) {
		self.init()
		_ = updateWith(serializedRepresentation)
	}
	
	func toSerializedRepresentation() -> NSDictionary {
		return [Countdown.countdownStartDateKey: startDate.timeIntervalSince1970, Countdown.countdownDurationKey: duration, Countdown.lastUpdatedKey: lastUpdated ?? 0]
	}
	
	func updateWith(_ serialized: SerializedRepresentation) -> Bool {
		guard let lastUpdated = serialized[Countdown.lastUpdatedKey] as? Int
		else {
			return false
		}
		self.lastUpdated = lastUpdated

		guard let startDateTimeStamp = serialized[Countdown.countdownStartDateKey] as? Double, let duration = serialized[Countdown.countdownDurationKey] as? Double
		else {
			return false
		}
		
		self.startDate = Date(timeIntervalSince1970: startDateTimeStamp)
		self.duration = duration
		
		return true
	}

}

func ==(lhs: Countdown, rhs: Countdown) -> Bool {
	return lhs.startDate == rhs.startDate && lhs.duration == rhs.duration
}
