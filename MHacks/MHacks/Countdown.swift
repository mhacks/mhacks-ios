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
    
    private static var formatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.minimumIntegerDigits = 2
        return formatter
    }()
    
    var timeRemainingDescription: String {
        
        let total = Int(round(timeRemaining))
        
        let hours = Countdown.formatter.stringFromNumber(total / 3600)!
        let minutes = Countdown.formatter.stringFromNumber((total % 3600) / 60)!
        let seconds = Countdown.formatter.stringFromNumber(total % 60)!
        
        return "\(hours):\(minutes):\(seconds)"
    }
    
    static let font: UIFont = {
        
        // This value is defined by Helvetica Neue to replace the standard color with a time separator
        let timeSeparatorValue = 1
        
        let featureSettings = [[UIFontFeatureTypeIdentifierKey: kCharacterAlternativesType, UIFontFeatureSelectorIdentifierKey: timeSeparatorValue]]
        
        let descriptor = UIFont(name: "HelveticaNeue-Thin", size: 120.0)!.fontDescriptor().fontDescriptorByAddingAttributes([UIFontDescriptorFeatureSettingsAttribute: featureSettings])
        
        return UIFont(descriptor: descriptor, size: 0.0)
    }()
    
    var progress: Double {
        return 1.0 - timeRemaining / duration
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
                
                completionHandler(self.currentCountdown())
                
            } else {
                
                completionHandler(Countdown(config: config))
            }
        }
    }
}
