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

class InterfaceController: WKInterfaceController {
    @IBOutlet var button: WKInterfaceButton!
    @IBOutlet var timerLabel: WKInterfaceLabel!
    @IBOutlet var decibel: WKInterfaceLabel!
    @IBOutlet var image: WKInterfaceImage!

    var graphValues: [NSNumber] = Array(repeating: 0.0, count: 100)
    var graphTimer: Timer?

    let microphone = MicrophoneController()
    let graph = GraphController()

    override init() {
        super.init()
        let monospacedFont = UIFont.monospacedDigitSystemFont(ofSize: 48, weight: UIFont.Weight.regular)
        let monospacedString = NSAttributedString(string: "0.00", attributes: [NSAttributedStringKey.font: monospacedFont])
        timerLabel.setAttributedText(monospacedString)
    }

    @objc func updateMeter() {
        overallTime = Date().timeIntervalSince(started!)
        if useMic {
            let decibels: Float = microphone.getDecibels()
            if triggered || decibels > threshold {
                if !pauseBelowThreshold {
                    triggered = true
                }

                if triggeredDate == nil {
                    triggeredDate = Date()
                } else {
                    aboveThresholdDiff = time + Date().timeIntervalSince(triggeredDate!)
                }
                updateTimerLabel(time: aboveThresholdDiff)
            } else {
                triggeredDate = nil
                time = aboveThresholdDiff
            }
        } else {
            updateTimerLabel(time: overallTime)
        }
    }

    func updateGraph() {
        let decibels: Float = microphone.getDecibels()
        decibel.setText(String(round(decibels)) + " db")
        graph.updateGraphValues(decibels: decibels)
        graph.drawGraph(width: WKInterfaceDevice.current().screenBounds.width, height: 75, scale: WKInterfaceDevice.current().screenScale) { graphImage in
            self.image.setImage(graphImage)
        }
    }

    func loadRecordingUI() {
        triggered = false
        button.setTitle("RESET")

        timer = Timer.scheduledTimer(
            withTimeInterval: 0.01,
            repeats: true
        ) { _ in self.updateMeter() }
        graphTimer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { _ in self.updateGraph() }
    }

    func loadFailUI() {
        timerLabel.setText("NO MIC")
    }

    func updateTimerLabel(time: Double) {
        let monospacedFont = UIFont.monospacedDigitSystemFont(ofSize: 48, weight: UIFont.Weight.regular)
        let timeString = String(round(10 * time) / 10)
        let monospacedString = NSAttributedString(string: timeString, attributes: [NSAttributedStringKey.font: monospacedFont])
        timerLabel.setAttributedText(monospacedString)
    }

    func start() {
        if !running {
            microphone.initRecorder { [unowned self] error in
                if error == nil {
                    running = true
                    started = Date()
                    self.loadRecordingUI()
                } else {
                    self.loadFailUI()
                }
            }
        }
    }

    func stop() {
        button.setTitle("START")
        timer?.invalidate()
        timer = nil
        time = 0.0
        graphTimer?.invalidate()
        graphTimer = nil
        timerLabel.setText(String(0.0))
        running = false
        triggered = false
        triggeredDate = nil

        microphone.closeRecorder()
    }

    @IBAction func click() {
        if !running {
            start()
        } else {
            stop()
        }
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // Configure interface objects here.
    }

    override func willActivate() {
        super.willActivate()
        active = true
        start()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        active = false
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 15,
            execute: {
                if !active {
                    self.stop()
                }
            }
        )
    }
}
