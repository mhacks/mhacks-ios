//
//  Configuration.swift
//  MHacks
//
//  Created by Connor Krupp on 8/28/17.
//  Copyright © 2017 MHacks. All rights reserved.
//

import UIKit

final class Configuration : Serializable, Equatable {
    
    // MARK : - Properties

    /// Be sure to update the == function at the bottom of this file if add property here.
    private(set) var startDate: Date
    private(set) var endDate: Date

    let semaphoreGuard = DispatchSemaphore(value: 1)
    let coalescer = CoalescedCallbacks()
    private(set) var lastUpdated: Int?
    
    private static let resultsKey = "configuration"
    private static let lastUpdatedKey = "updatedAt_ts"
    private static let startDateKey = "start_date_ts"
    private static let endDateKey = "end_date_ts"

    init(startDate: Date = Date(timeIntervalSince1970: 150603840), endDate: Date = Date(timeIntervalSince1970: 150621120)) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    convenience init?(_ serializedRepresentation: SerializedRepresentation) {
        self.init()
        _ = updateWith(serializedRepresentation)
    }
    
    func toSerializedRepresentation() -> NSDictionary {
        return [
            Configuration.resultsKey: [
                Configuration.startDateKey: startDate.timeIntervalSince1970 * 1000,
                Configuration.endDateKey: endDate.timeIntervalSince1970 * 1000,
                Configuration.lastUpdatedKey: lastUpdated ?? 0
            ]
        ]
    }
    
    func updateWith(_ serialized: SerializedRepresentation) -> Bool {
        guard let config = serialized["configuration"] as? [String: Any] else {
            return false
        }
        
        guard let startDate = config[Configuration.startDateKey] as? Double,
              let endDate = config[Configuration.endDateKey] as? Double
        else {
            return false
        }
        
        self.startDate = Date(timeIntervalSince1970: startDate / 1000)
        self.endDate = Date(timeIntervalSince1970: endDate / 1000)
        
        if let updatedAtTimestamp = config[Configuration.lastUpdatedKey] as? Int {
            self.lastUpdated = updatedAtTimestamp
        }
        
        return true
    }
    
    // MARK: Countdown Formatting
    
    func progress(for date: Date = Date()) -> Double {
        return 1.0 - self.timeRemaining(for: date) / self.duration
    }
    
    private func progressDate(for date: Date = Date()) -> Date {
        return min(max(date, self.startDate), endDate)
    }
    
    private func timeRemaining(for date: Date = Date()) -> TimeInterval {
        return self.endDate.timeIntervalSince(progressDate(for: date))
    }
    
    private var duration: TimeInterval {
        return self.endDate.timeIntervalSince1970 - self.startDate.timeIntervalSince1970
    }
    
    private var roundedTimeRemaining: TimeInterval {
        return round(self.timeRemaining())
    }
    
    var timeRemainingDescription: String {
        
        let total = Int(self.roundedTimeRemaining)
        
        let hours = Configuration.timeRemainingFormatter.string(for: total / 3600)!
        let minutes = Configuration.timeRemainingFormatter.string(for: (total % 3600) / 60)!
        let seconds = Configuration.timeRemainingFormatter.string(for: total % 60)!
        
        return "\(hours):\(minutes):\(seconds)"
    }
    
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
    
    var startDateDescription: String {
        let message: String = {
            if self.roundedCurrentDate > self.startDate {
                return NSLocalizedString("Hacking started\n%@.", comment: "Countdown hacking did start")
            } else {
                return NSLocalizedString("Hacking starts\n%@.", comment: "Countdown hacking will start")
            }
        }()
        
        let dateText = Configuration.dateFormatter.string(from: startDate)
        
        return String(format: message, dateText)
    }
    
    var endDateDescription: String {
        let dateText = Configuration.dateFormatter.string(from: self.endDate)
        
        if self.roundedCurrentDate < self.endDate {
            let message = NSLocalizedString("Hacking finishes\n%@.", comment: "Countdown hacking will end")
            return String(format: message, dateText)
        } else {
            let message = NSLocalizedString("Hacking finished\n%@.", comment: "Countdown hacking did end")
            return String(format: message, dateText)
        }
    }
    
    private var roundedCurrentDate: Date {
        return self.startDate.addingTimeInterval(self.duration - self.roundedTimeRemaining)
    }
}

func ==(lhs: Configuration, rhs: Configuration) -> Bool {
    return lhs.startDate == rhs.startDate && lhs.endDate == rhs.endDate
}
