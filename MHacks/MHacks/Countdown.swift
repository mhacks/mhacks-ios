//
//  Countdown.swift
//  MHacks
//
//  Created by Russell Ladd on 11/12/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

struct Countdown {
    
    let startDate: NSDate
    let duration: NSTimeInterval
    let message: String
    
    var endDate: NSDate {
        return startDate.dateByAddingTimeInterval(duration)
    }
    
    // The current date clipped to the start and end of the event
    var progressDate: NSDate {
        return NSDate().laterDate(startDate).earlierDate(endDate);
    }
    
    var timeRemaining: NSTimeInterval {
        return endDate.timeIntervalSinceDate(progressDate)
    }
    
    private static var Formatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.minimumIntegerDigits = 2
        return formatter
    }()
    
    var localizedTimeRemaining: String {
        
        let total = Int(round(timeRemaining))
        
        let hours = Countdown.Formatter.stringFromNumber(total / 3600)!
        let minutes = Countdown.Formatter.stringFromNumber((total % 3600) / 60)!
        let seconds = Countdown.Formatter.stringFromNumber(total % 60)!
        
        return "\(hours):\(minutes):\(seconds)"
    }
    
    private init?(config: PFConfig) {
        
        let startDate = config["countdownStartDate"] as? NSDate
        let duration = (config["countdownDuration"] as? NSNumber)?.doubleValue
        let message = config["countdownMessage"] as? String
        
        if (startDate == nil || duration == nil || message == nil) {
            return nil
        }
        
        self.startDate = startDate!
        self.duration = duration!
        self.message = message!
    }
    
    static func currentCountdown() -> Countdown? {
        return Countdown(config: PFConfig.currentConfig())
    }
    
    static func fetchCountdown(completionHandler: Countdown? -> Void) {
        
        PFConfig.getConfigInBackgroundWithBlock { config, error in
            
            if (error != nil) {
                
                completionHandler(nil)
                
            } else {
                
                completionHandler(Countdown(config: config))
            }
        }
    }
}
