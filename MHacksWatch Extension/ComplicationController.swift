//
//  ComplicationController.swift
//  MHacksWatch Extension
//
//  Created by Manav Gabhawala on 10/3/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import ClockKit

protocol CLKComplicationTemplateRingImage: class
{
    var imageProvider: CLKImageProvider { get set }
    var fillFraction: Float { get set }
    var ringStyle: CLKComplicationRingStyle { get set }
    var tintColor: UIColor? { get set }
    @nonobjc static var imageString: String { get }
    init()
}

@available(watchOSApplicationExtension 3.0, *)
extension CLKComplicationTemplateExtraLargeRingImage: CLKComplicationTemplateRingImage {
    @nonobjc static let imageString = "Complication/Extra Large"
}
extension CLKComplicationTemplateCircularSmallRingImage: CLKComplicationTemplateRingImage {
    @nonobjc static let imageString = "Complication/Circular"
}
extension CLKComplicationTemplateModularSmallRingImage: CLKComplicationTemplateRingImage {
    @nonobjc static let imageString = "Complication/Modular"
}
extension CLKComplicationTemplateUtilitarianSmallRingImage: CLKComplicationTemplateRingImage {
    @nonobjc static let imageString = "Complication/Utilitarian"
}


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    func requestedUpdateDidBegin() {
        APIManager.shared.updateConfiguration() { succeeded in
            guard succeeded
            else { return }
            CLKComplicationServer.sharedInstance().activeComplications?.forEach {
                CLKComplicationServer.sharedInstance().reloadTimeline(for: $0)
            }
        }
    }
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(APIManager.shared.configuration.startDate)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(APIManager.shared.configuration.endDate)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        guard let template = complicationTemplate(for: complication)?.init()
        else {
            handler(nil)
            return
        }
        handler(createTimeLineEntry(for: template))
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        guard let template = complicationTemplate(for: complication)?.init()
        else {
            handler(nil)
            return
        }
        let dates: [Date] = (-limit..<0).map { i in
            return date.addingTimeInterval(TimeInterval(i) * 60.0 * 10.0) // Ten minutes
        }
        handler(dates.map { createTimeLineEntry(for: template, for: $0) })
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        
        guard let template = complicationTemplate(for: complication)?.init()
        else {
            handler(nil)
            return
        }
        let dates: [Date] = (1...limit).map { i in
            return date.addingTimeInterval(TimeInterval(i) * 60.0 * 10.0) // Ten minutes
        }
        handler(dates.map { createTimeLineEntry(for: template, for: $0) })
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        handler(nil)
    }
    
    // MARK: - Helper
    func createTimeLineEntry(for template: CLKComplicationTemplateRingImage, for date: Date = Date()) -> CLKComplicationTimelineEntry {
        template.ringStyle = .closed
        template.fillFraction = Float(APIManager.shared.configuration.progress(for: date))
        template.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: type(of: template).imageString)!)
        template.tintColor = MHacksColor.blue
        
        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template as! CLKComplicationTemplate)
    }
    func complicationTemplate(for complication: CLKComplication) -> CLKComplicationTemplateRingImage.Type? {
        switch complication.family {
        case .modularSmall:
            return CLKComplicationTemplateModularSmallRingImage.self
        case .circularSmall:
            return CLKComplicationTemplateCircularSmallRingImage.self
        case .utilitarianSmall:
            return CLKComplicationTemplateCircularSmallRingImage.self
        case .extraLarge:
            if #available(watchOSApplicationExtension 3.0, *) {
                return CLKComplicationTemplateExtraLargeRingImage.self
            } else {
                return CLKComplicationTemplateCircularSmallRingImage.self
            }
        default:
            return nil
        }
    }
}
