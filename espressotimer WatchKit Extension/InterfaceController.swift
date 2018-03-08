//
//  InterfaceController.swift
//  espressotimer WatchKit Extension
//
//  Created by Hans-Wilhelm Warlo on 21/02/2018.
//  Copyright © 2018 Hans-Wilhelm Warlo. All rights reserved.
//

import WatchKit
import AVFoundation
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var button: WKInterfaceButton!
    @IBOutlet var timerLabel: WKInterfaceLabel!
    @IBOutlet var mic: WKInterfaceLabel!
    @IBOutlet var sensitivity: WKInterfaceSlider!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var recorder : AVAudioRecorder? = nil
    
    var time = 0.0
    var threshold : Float = -40.0
    var running = false
    var timer : Timer?
    var useMic = true
    
    @IBOutlet var test: WKInterfaceLabel!
    
    @IBAction func sensitivityChange(_ value: Float) {
        test.setText(String(value) + "db")
        threshold = value
    }
    
    @IBAction func toggleMic(_ value: Bool) {
        useMic = value
        test.setText(String(useMic))
    }
    
    @IBAction func click() {
        if useMic {
            self.run()
        }
        WKInterfaceDevice.current().play(.success)
        
        running = !running
        if running {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        } else {
            button.setTitle("START")
            timer?.invalidate()
            timer = nil
            time = 0.0
            timerLabel.setText(String(0.0))
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
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            try self.recordingSession.setCategory(AVAudioSessionCategoryRecord)
            try self.recordingSession.setActive(true)
            try recorder = AVAudioRecorder(url: getDocumentsDirectory(), settings: settings)
            recorder!.isMeteringEnabled = true
            if !recorder!.prepareToRecord() {
                self.loadFailUI()
                print("Error: AVAudioRecorder prepareToRecord failed")
            }
        } catch {
            self.loadFailUI()
            print("Error: AVAudioRecorder creation failed")
        }
    }
    
    func start() {
        recorder?.record()
        recorder?.updateMeters()
    }
    
    func stop() {
        recorder?.stop()
        recorder?.deleteRecording()
    }
    
    func loadRecordingUI() {
        self.initRecorder()
        self.start()
    }
    
    func loadFailUI() {
        timerLabel.setText("NO MIC")
    }
    
    @objc func update() {
        if useMic {
            var decibels : Float = -120.0
            if let recorder = recorder {
                recorder.updateMeters()
                decibels = recorder.averagePower(forChannel: 0)
                mic.setText(String(round(decibels)))
            }
            if decibels > threshold {
                self.updateTimerLabel()
            }
        } else {
            self.updateTimerLabel()
        }
    }
    
    func updateTimerLabel() {
        time += 0.1
        timerLabel.setText(String(round(10*time) / 10))
    }
    
    func run() {
        recordingSession = AVAudioSession.sharedInstance()
        
        recordingSession.requestRecordPermission () {
            [unowned self] allowed in
            if allowed {
                self.loadRecordingUI()
            }
            else {
                self.loadFailUI()
            }
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func willDisappear() {
        super.willDisappear()
    }

}
