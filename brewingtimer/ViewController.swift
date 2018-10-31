//
//  ViewController.swift
//  brewingtimer
//
//  Created by Hans-Wilhelm Warlo on 21/02/2018.
//  Copyright © 2018 Hans-Wilhelm Warlo. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit
import YOChartImageKit

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var button: UIButton!
    @IBOutlet var decibel: UILabel!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var image: UIImageView!

    var graphTimer: Timer?

    let microphone = MicrophoneController()
    let graph = GraphController()

    @objc func update() {
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
        decibel.text = String(round(decibels)) + " db"
        graph.updateGraphValues(decibels: decibels)
        graph.drawGraph(width: image.bounds.width, height: 150, scale: UIScreen.main.scale) { graphImage in
            self.image.image = graphImage
        }
    }

    func loadRecordingUI() {
        triggered = false
        button.setTitle("RESET", for: .normal)
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.01,
            repeats: true
        ) { _ in self.update() }
        graphTimer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { _ in self.updateGraph() }
    }

    func loadFailUI() {
        timerLabel.text = "NO MIC"
    }

    func updateTimerLabel(time: Double) {
        timerLabel.text = String(format: "%.02f", time)
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
        button.setTitle("START", for: .normal)
        timer?.invalidate()
        timer = nil
        time = 0.0
        graphTimer?.invalidate()
        graphTimer = nil
        timerLabel.text = "0.0"
        running = false
        triggered = false
        started = nil
        triggeredDate = nil

        microphone.closeRecorder()
    }

    @IBAction func click(_: Any?) {
        if !running {
            start()
        } else {
            stop()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsButton.setTitle(
            NSString(string: "\u{2699}\u{0000FE0E}") as String,
            for: UIControlState.normal
        )
        active = true
        start()
    }

    override func viewDidAppear(_: Bool) {
        active = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        active = false
        // Stop the microphone 15 seconds after leaving app
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 15,
            execute: {
                if !active {
                    self.stop()
                }
            }
        )
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
