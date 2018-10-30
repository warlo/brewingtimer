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

    let graph = GraphController()
    var graphValues: [NSNumber] = Array(repeating: 0.0, count: 100)
    var graphTimer: Timer?

    var running: Bool = false

    @IBAction func click() {
        if !running {
            run()
        } else {
            stop()
        }
    }

    func getDocumentsDirectory() -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls.first!
        return documentDirectory.appendingPathComponent("recording.m4a")
    }

    func initRecorder() {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryRecord)
            try recordingSession.setActive(true)
            recorder = try AVAudioRecorder(
                url: getDocumentsDirectory(),
                settings: settings
            )
            recorder!.isMeteringEnabled = true
            if !recorder!.prepareToRecord() {
                loadFailUI()
                print("Error: AVAudioRecorder prepareToRecord failed")
            }
        } catch {
            loadFailUI()
            print("Error: AVAudioRecorder creation failed")
        }
    }

    func start() {
        recorder?.record()
        recorder?.updateMeters()
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
        recorder?.stop()
        recorder?.deleteRecording()
        do {
            try recordingSession.setActive(false)
        } catch {
            loadFailUI()
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
        if useMic {
            initRecorder()
            start()
        }
        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(updateMeter),
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

    func loadFailUI() {
        timerLabel.setText("NO MIC")
    }

    @objc func updateMeter() {
        if useMic {
            var decibels: Float = -120.0
            if let recorder = recorder {
                recorder.updateMeters()
                decibels = recorder.averagePower(forChannel: 0)
                decibel.setText(String(round(decibels)) + " db")
            }
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

    func updateTimerLabel() {
        time += 0.1
        timerLabel.setText(String(round(10 * time) / 10))
    }

    func run() {
        if !running {
            running = true
            recordingSession = AVAudioSession.sharedInstance()
            recordingSession.requestRecordPermission { [unowned self] allowed in
                if allowed {
                    self.loadRecordingUI()
                } else {
                    self.loadFailUI()
                }
            }
        }
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // Configure interface objects here.
    }

    override func willActivate() {
        super.willActivate()
        active = true
        run()
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
