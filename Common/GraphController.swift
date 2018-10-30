//
//  GraphController.swift
//  brewingtimer
//
//  Created by Hans-Wilhelm Warlo on 30/10/2018.
//  Copyright © 2018 Hans-Wilhelm Warlo. All rights reserved.
//

import Foundation
import YOChartImageKit

class GraphController {
    func drawGraph(
        graphValues: [NSNumber],
        width: CGFloat,
        height: CGFloat,
        scale: CGFloat,
        completion: @escaping (UIImage) -> Void
    ) {
        let chart = YOLineChartImage()
        let chart2 = YOLineChartImage()

        chart.strokeWidth = 2.0
        chart.fillColor = UIColor(red: 0.0, green: 1.00, blue: 0.0, alpha: 0.5)
        chart.strokeColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        chart.values = graphValues
        chart.maxValue = 100

        let middle = NSNumber(value: (threshold + 90.0))
        chart2.values = [middle, middle]
        chart2.maxValue = 100
        chart2.strokeColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let size = CGSize(width, height)

        UIGraphicsBeginImageContext(size)
        let frame = CGRect(0, 0, size.width, size.height)
        let drawImg = chart.draw(frame, scale: scale)
        let drawImg2 = chart2.draw(frame, scale: scale)
        drawImg.draw(in: frame)
        drawImg2.draw(in: frame, blendMode: .normal, alpha: 1.0)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        completion(newImage)
    }
}
