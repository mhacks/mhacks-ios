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
            
            switch self.roundedCurrentDate?.compare(self.startDate!) ?? .OrderedAscending {
            case .OrderedAscending, .OrderedSame:
                return NSLocalizedString("Hacking starts\n%@.", comment: "Countdown hacking will start")
            case .OrderedDescending:
                return NSLocalizedString("Hacking started\n%@.", comment: "Countdown hacking did start")
            }
        }()
        
        let dateText = startDate != nil ? Countdown.dateFormatter.stringFromDate(startDate!) : "…"
        
        return NSString(format: message, dateText) as String
    }
    
    var endDateDescription: String {
        
        let message: String = {
            
            switch self.roundedCurrentDate?.compare(self.endDate!) ?? .OrderedAscending {
            case .OrderedAscending:
                return NSLocalizedString("Hacks must be submitted by\n%@.", comment: "Countdown hacking will end")
            case .OrderedSame, .OrderedDescending:
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
        
        // This value is defined by Helvetica Neue to replace the standard colon with a time separator
        let timeSeparatorValue = 1
        
        let featureSettings = [[UIFontFeatureTypeIdentifierKey: kCharacterAlternativesType, UIFontFeatureSelectorIdentifierKey: timeSeparatorValue]]
        
        let descriptor = UIFont(name: "HelveticaNeue-Thin", size: 120.0)!.fontDescriptor().fontDescriptorByAddingAttributes([UIFontDescriptorFeatureSettingsAttribute: featureSettings])
        
        return UIFont(descriptor: descriptor, size: 0.0)
    }()
    
    var progress: Double {
        return 1.0 - timeRemaining / duration
    }
    
	init(startDate: NSDate? = nil, duration: NSTimeInterval = 129600) {
        
        self.startDate = startDate
        self.duration = duration
    }
    
//    private init?(config: PFConfig) {
//        
//        let startDate = config["countdownStartDate"] as? NSDate
//        let duration = (config["countdownDuration"] as? NSNumber)?.doubleValue
//        
//        if (startDate == nil || duration == nil) {
//            return nil
//        }
//        
//        self.startDate = startDate!
//        self.duration = duration!
//    }
//    
//    static func currentCountdown() -> Countdown? {
//        return Countdown(config: PFConfig.currentConfig())
//    }
//    
//    static func fetchCountdown(completionHandler: Countdown? -> Void) {
//        
//        PFConfig.getConfigInBackgroundWithBlock { config, error in
//            
//            if (error != nil) {
//                
//                completionHandler(nil)
//                
//            } else {
//                
//                completionHandler(Countdown(config: config))
//            }
//        }
//    }
}
