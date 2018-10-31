//
//  Global.swift
//  brewingtimer
//
//  Created by Hans-Wilhelm Warlo on 11/03/2018.
//  Copyright © 2018 Hans-Wilhelm Warlo. All rights reserved.
//

import Foundation
import YOChartImageKit

var overallTime: Double = 0.0
var time: Double = 0.0
var started: Date?
var triggeredDate: Date?
var aboveThresholdDiff = 0.0

var thresholdPhone: Float = -25.0
var thresholdWatch: Float = -40.0
var running = false
var timer: Timer?
var useMic = true
var pauseBelowThreshold = true
var triggered = false
var active = false

extension CGRect {
    init(
        _ xPoint: CGFloat,
        _ yPoint: CGFloat,
        _ width: CGFloat,
        _ height: CGFloat
    ) {
        self.init(x: xPoint, y: yPoint, width: width, height: height)
    }
}

extension CGSize {
    init(_ width: CGFloat, _ height: CGFloat) {
        self.init(width: width, height: height)
    }
}

extension CGPoint {
    init(_ xPoint: CGFloat, _ yPoint: CGFloat) {
        self.init(x: xPoint, y: yPoint)
    }
}
