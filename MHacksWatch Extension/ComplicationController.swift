//
//  ComplicationController.swift
//  MHacksWatch Extension
//
//  Created by Manav Gabhawala on 10/3/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
//        handler([.forward, .backward])
        handler([])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
//        APIManager.shared.updateCountdown { _ in
//            handler(APIManager.shared.countdown.startDate)
//        }
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
//        APIManager.shared.updateCountdown { _ in
//            handler(APIManager.shared.countdown.endDate)
//        }
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        APIManager.shared.updateCountdown { _ in
            switch complication.family {
            case .modularSmall:
                let complication = CLKComplicationTemplateModularSmallRingText()
//                let complication = CLKComplicationTemplateModularSmallRingImage()
                complication.ringStyle = .closed
                complication.fillFraction = 0.5 // Float(APIManager.shared.countdown.progress)
                complication.tintColor = MHacksColor.blue
//                complication.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "")!)
                complication.textProvider = CLKSimpleTextProvider(text: "M")
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: complication))
                break
            case .modularLarge:
                break
            case .circularSmall:
                break
            case .extraLarge:
                break
            default:
                break
            }
            
            handler(nil)

        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }
    
}
