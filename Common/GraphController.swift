//
//  GraphController.swift
//  brewingtimer
//
//  Created by Hans-Wilhelm Warlo on 30/10/2018.
//  Copyright © 2018 Hans-Wilhelm Warlo. All rights reserved.
//

import YOChartImageKit

class GraphController {
    var graphValues: [NSNumber] = Array(repeating: 0.0, count: 100)
    let offset: Float = 90.0

    func updateGraphValues(decibels: Float) {
        graphValues.removeFirst()
        graphValues.append(NSNumber(value: (decibels + offset)))
    }

    func clearGraph() {
        graphValues = Array(repeating: 0.0, count: 100)
    }

    func drawGraph(
        width: CGFloat,
        height: CGFloat,
        scale: CGFloat,
        completion: @escaping (UIImage) -> Void
    ) {
        let waveform = YOLineChartImage()
        let thresholdLine = YOLineChartImage()

        waveform.strokeWidth = 2.0
        waveform.fillColor = UIColor(red: 0.0, green: 1.00, blue: 0.0, alpha: 0.5)
        waveform.strokeColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        waveform.values = graphValues
        waveform.maxValue = 100

        let middle = NSNumber(value: (threshold + 90.0))
        thresholdLine.values = [middle, middle]
        thresholdLine.maxValue = 100
        thresholdLine.strokeColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)

        let size = CGSize(width, height)
        let frame = CGRect(0, 0, size.width, size.height)
        let drawWaveform = waveform.draw(frame, scale: scale)
        let drawThresholdLine = thresholdLine.draw(frame, scale: scale)
        UIGraphicsBeginImageContext(size)
        drawWaveform.draw(in: frame)
        drawThresholdLine.draw(in: frame, blendMode: .normal, alpha: 1.0)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        completion(newImage)
    }
}
