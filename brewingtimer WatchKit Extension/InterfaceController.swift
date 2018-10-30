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

    var recordingSession: AVAudioSession!
    var recorder: AVAudioRecorder!

    @IBOutlet var test: WKInterfaceLabel!

    var graphValues: [NSNumber] = Array(repeating: 0.0, count: 100)
    var graphTimer: Timer?

    let microphone = MicrophoneController()
    let graph = GraphController()

    @objc func updateMeter() {
        if useMic {
            let decibels: Float = microphone.getDecibels()
            decibel.setText(String(round(decibels)) + " db")
            if triggered || decibels > threshold {
                if !pauseBelowThreshold {
                    triggered = true
                }
                updateTimerLabel()
            }
            graphValues.append(NSNumber(value: (decibels + 90.0)))
            graphValues.removeFirst()
        } else {
            updateTimerLabel()
        }
    }

    @objc func updateGraph() {
        graph.drawGraph(graphValues: graphValues, width: WKInterfaceDevice.current().screenBounds.width, height: 75, scale: WKInterfaceDevice.current().screenScale) { graphImage in
            self.image.setImage(graphImage)
        }
    }

    func loadRecordingUI() {
        triggered = false
        button.setTitle("RESET")

        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(updateMeter),
            userInfo: nil,
            repeats: true
        )
        if useMic {
            graphTimer = Timer.scheduledTimer(
                timeInterval: 0.1,
                target: self,
                selector: #selector(updateGraph),
                userInfo: nil,
                repeats: true
            )
        }
    }

    func loadFailUI() {
        timerLabel.setText("NO MIC")
    }

    func updateTimerLabel() {
        time += 0.1
        timerLabel.setText(String(round(10 * time) / 10))
    }

    func start() {
        if !running {
            microphone.initRecorder { [unowned self] error in
                if error == nil {
                    running = true
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
