//
//  ComplicationController.swift
//  brewingtimer WatchKit Extension
//
//  Created by Hans-Wilhelm Warlo on 31/10/2018.
//  Copyright © 2018 Hans-Wilhelm Warlo. All rights reserved.
//

import ClockKit
import Foundation

class ComplicationController: NSObject, CLKComplicationDataSource {
    func getSupportedTimeTravelDirections(for _: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        // Turn off time travelling
        handler([])
    }

    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        var template: CLKComplicationTemplate?

        switch complication.family {
        case .circularSmall:
            let modTemplate = CLKComplicationTemplateCircularSmallRingImage()
            modTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Cirular")!)
            template = modTemplate
        case .utilitarianSmall:
            let modTemplate = CLKComplicationTemplateUtilitarianSmallRingImage()
            modTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Utilitarian")!)
            template = modTemplate
        case .modularSmall:
            let modTemplate = CLKComplicationTemplateModularSmallRingImage()
            modTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Modular")!)
            template = modTemplate
        case .modularLarge:
            abort()
        case .utilitarianLarge:
            abort()
        case .utilitarianSmallFlat:
            let modTemplate = CLKComplicationTemplateModularSmallRingImage()
            modTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Utilitarian")!)
            template = modTemplate
        case .extraLarge:
            abort()
        case .graphicCorner:
            abort()
        case .graphicBezel:
            abort()
        case .graphicCircular:
            abort()
        case .graphicRectangular:
            abort()
        }

        handler(template)
    }

    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        var template: CLKComplicationTemplate?
        switch complication.family {
        case .circularSmall:
            let modTemplate = CLKComplicationTemplateCircularSmallRingImage()
            modTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Circular")!)
            template = modTemplate
        case .utilitarianSmall:
            let modTemplate = CLKComplicationTemplateUtilitarianSmallRingImage()
            modTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Utilitarian")!)
            template = modTemplate
        case .modularSmall:
            let modTemplate = CLKComplicationTemplateModularSmallRingImage()
            modTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Modular")!)
            template = modTemplate
        case .utilitarianSmallFlat:
            let modTemplate = CLKComplicationTemplateModularSmallRingImage()
            modTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Utilitarian")!)
            template = modTemplate
        default:
            template = nil
            handler(nil)
        }
        if template != nil {
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template!)
            handler(timelineEntry)
        }
    }
}
