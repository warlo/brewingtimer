//
//  ViewController.swift
//  espressotimer
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
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var recorder : AVAudioRecorder? = nil
    
    var time = 0.0
    var running = false
    var timer : Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.run()
        self.click(nil)
    }
    
    @IBAction func click(_ sender: Any?) {
        running = !running
        if running {
            button.setTitle("RESET", for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        } else {
            button.setTitle("START", for: .normal)
            timer?.invalidate()
            timer = nil
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
            try recorder = AVAudioRecorder(url: getDocumentsDirectory(), settings: settings)
            recorder!.isMeteringEnabled = true
            if !recorder!.prepareToRecord() {
                print("Error: AVAudioRecorder prepareToRecord failed")
            }
        } catch {
            print("Error: AVAudioRecorder creation failed")
        }
    }

    func start() {
        recorder?.record()
        recorder?.updateMeters()
    }
    
    func loadRecordingUI() {
        button.setTitle("YEY", for: .normal)
        do {
            try self.recordingSession.setCategory(AVAudioSessionCategoryRecord)
            try self.recordingSession.setActive(true)
            self.initRecorder()
            self.start()
        } catch {
            self.loadFailUI()
        }
        
    }
    
    func loadFailUI() {
        button.setTitle("NAY", for: .normal)
    }
    
    @objc func update() {
        var decibels : Float = -120.0
        if let recorder = recorder {
            recorder.updateMeters()
            decibels = recorder.averagePower(forChannel: 0)
            mic.text = String(decibels)
        }
        if decibels > -30.0 {
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

