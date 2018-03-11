//
//  ViewController.swift
//  brewingtimer
//
//  Created by Hans-Wilhelm Warlo on 21/02/2018.
//  Copyright © 2018 Hans-Wilhelm Warlo. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var mic: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var recorder : AVAudioRecorder? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.settingsButton.setTitle(NSString(string: "\u{2699}\u{0000FE0E}") as String, for: UIControlState.normal)
    }
    
    @IBAction func click(_ sender: Any?) {
        self.run()
        running = !running
        if running {
            button.setTitle("RESET", for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        } else {
            button.setTitle("START", for: .normal)
            timer?.invalidate()
            timer = nil
            time = 0.0
            timerLabel.text = "0.0"
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
            try recorder = AVAudioRecorder(url: getDocumentsDirectory(), settings: settings)
            try self.recordingSession.setActive(true)
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
        timerLabel.text = "NO MIC"
    }
    
    @objc func update() {
        var decibels : Float = -120.0
        if let recorder = recorder {
            recorder.updateMeters()
            decibels = recorder.averagePower(forChannel: 0)
            mic.text = String(decibels)
        }
        if decibels > threshold {
            time += 0.1
            timerLabel.text = (String(round(10*time) / 10))
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

