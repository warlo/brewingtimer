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

    var recordingSession: AVAudioSession!
    var recorder: AVAudioRecorder!

    var graphValues: [NSNumber] = Array(repeating: 0.0, count: 100)
    var graphTimer: Timer?

    var threshold = thresholdPhone

    @IBAction func click(_: Any?) {
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
            recorder.isMeteringEnabled = true
            if !recorder.prepareToRecord() {
                loadFailUI()
                print("Error: AVAudioRecorder prepareToRecord failed")
            }
        } catch {
            loadFailUI()
            print("Error: AVAudioRecorder creation failed")
        }
    }

    func start() {
        recorder.record()
        recorder.updateMeters()
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
        recorder.stop()
        recorder.deleteRecording()
        do {
            try recordingSession.setActive(false)
        } catch {
            loadFailUI()
        }
    }

    @objc func updateGraph() {
        let chart = YOLineChartImage()

        chart.strokeWidth = 2.0
        chart.fillColor = UIColor(red: 0.0, green: 1.00, blue: 0.0, alpha: 0.5)
        chart.values = graphValues
        chart.maxValue = 100
        let chart2 = YOLineChartImage()
        chart.strokeWidth = 2.0
        chart.strokeColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)

        let middle = NSNumber(value: (threshold + 90.0))
        chart2.values = [middle, middle]
        chart2.maxValue = 100
        chart2.strokeColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let size = CGSize(image.bounds.width, 150)
        UIGraphicsBeginImageContext(size)
        let frame = CGRect(0, 0, size.width, size.height)
        let drawImg = chart.draw(frame, scale: UIScreen.main.scale)
        let drawImg2 = chart2.draw(frame, scale: UIScreen.main.scale)
        drawImg.draw(in: frame)
        drawImg2.draw(in: frame, blendMode: .normal, alpha: 1.0)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        image.image = newImage
    }

    func loadRecordingUI() {
        triggered = false
        button.setTitle("RESET", for: .normal)
        if useMic {
            initRecorder()
            start()
        }
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

    func loadFailUI() {
        timerLabel.text = "NO MIC"
    }

    @objc func update() {
        if useMic {
            var decibels: Float = -120.0
            if let recorder = recorder {
                recorder.updateMeters()
                decibels = recorder.averagePower(forChannel: 0)
                decibel.text = String(round(decibels)) + " db"
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
        timerLabel.text = String(round(10 * time) / 10)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        settingsButton.setTitle(
            NSString(string: "\u{2699}\u{0000FE0E}") as String,
            for: UIControlState.normal
        )
        active = true
        run()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
