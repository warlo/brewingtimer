//
//  InterfaceController.swift
//  brewingtimer WatchKit Extension
//
//  Created by Hans-Wilhelm Warlo on 21/02/2018.
//  Copyright © 2018 Hans-Wilhelm Warlo. All rights reserved.
//

import AVFoundation
import Foundation
import WatchKit
import YOChartImageKit

class InterfaceController: WKInterfaceController, CommonController {
    @IBOutlet var button: WKInterfaceButton!
    @IBOutlet var timerLabel: WKInterfaceLabel!
    @IBOutlet var decibel: WKInterfaceLabel!
    @IBOutlet var image: WKInterfaceImage!

    var microphone = MicrophoneController()
    var graph = GraphController()

    func getGraph() -> GraphController {
        return graph
    }

    func getMicrophone() -> MicrophoneController {
        return microphone
    }

    func getDimensions() -> (width: CGFloat, height: CGFloat, scale: CGFloat) {
        return (WKInterfaceDevice.current().screenBounds.width, 75, WKInterfaceDevice.current().screenScale)
    }

    func loadFailUI() {
        timerLabel.setText("NO MIC")
    }

    func updateDecibelLabel(decibels: Float) {
        decibel.setText(String(round(decibels)) + " db")
    }

    func updateTimerLabel(time: Double) {
        let monospacedFont = UIFont.monospacedDigitSystemFont(ofSize: 48, weight: UIFont.Weight.regular)
        let timeString = String(round(10 * time) / 10)
        let monospacedString = NSAttributedString(string: timeString, attributes: [NSAttributedStringKey.font: monospacedFont])
        timerLabel.setAttributedText(monospacedString)
    }

    func updateImage(image: UIImage) {
        self.image.setImage(image)
    }

    func updateButtonText(text: String) {
        button.setTitle(text)
    }

    @IBAction func click() {
        if !running {
            start()
        } else {
            stop()
        }
    }

    override func willActivate() {
        super.willActivate()
        onLoad()
        onAppear()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        onDisappear()
    }
}
