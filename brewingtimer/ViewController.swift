//
//  ViewController.swift
//  brewingtimer
//
//  Created by Hans-Wilhelm Warlo on 21/02/2018.
//  Copyright © 2018 Hans-Wilhelm Warlo. All rights reserved.
//

import AVFoundation
import UIKit
import YOChartImageKit

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var button: UIButton!
    @IBOutlet var decibel: UILabel!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var image: UIImageView!

    var graphValues: [NSNumber] = Array(repeating: 0.0, count: 100)
    var graphTimer: Timer?

    let microphone = MicrophoneController()
    let graph = GraphController()

    @objc func updateGraph() {
        graph.drawGraph(graphValues: graphValues, width: image.bounds.width, height: 150, scale: UIScreen.main.scale) { graphImage in
            self.image.image = graphImage
        }
    }

    func loadRecordingUI() {
        triggered = false
        button.setTitle("RESET", for: .normal)
        if useMic {
            timer = Timer.scheduledTimer(
                timeInterval: 0.1,
                target: self,
                selector: #selector(update),
                userInfo: nil,
                repeats: true
            )
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
        timerLabel.text = "NO MIC"
    }

    func updateTimerLabel() {
        time += 0.1
        timerLabel.text = String(round(10 * time) / 10)
    }

    @objc func update() {
        if useMic {
            let decibels: Float = microphone.getDecibels()
            decibel.text = String(round(decibels)) + " db"
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
        button.setTitle("START", for: .normal)
        timer?.invalidate()
        timer = nil
        time = 0.0
        graphTimer?.invalidate()
        graphTimer = nil
        timerLabel.text = "0.0"
        running = false
        triggered = false

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
