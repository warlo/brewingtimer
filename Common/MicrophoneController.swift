
//
//  MicrophoneController.swift
//  brewingtimer
//
//  Created by Hans-Wilhelm Warlo on 29/10/2018.
//  Copyright © 2018 Hans-Wilhelm Warlo. All rights reserved.
//

import AVFoundation
import Foundation

class MicrophoneController {
    let recordingSession: AVAudioSession! = AVAudioSession.sharedInstance()
    var recorder: AVAudioRecorder!

    let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
    ]

    func getDocumentsDirectory() -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls.first!
        return documentDirectory.appendingPathComponent("recording.m4a")
    }

    func setupRecorder(completion: @escaping (Error?) -> Void) {
        try! recordingSession.setCategory(AVAudioSessionCategoryRecord)
        try! recordingSession.setActive(true)
        recorder = try! AVAudioRecorder(
            url: getDocumentsDirectory(),
            settings: settings
        )
        recorder!.isMeteringEnabled = true
        if !recorder!.prepareToRecord() {
            print("Error: AVAudioRecorder prepareToRecord failed")
            completion((AVAudioSessionErrorCode.codeUnspecified as! Error))
        }
        completion(nil)
        recorder.record()
        recorder.updateMeters()
    }

    func getDecibels() -> Float {
        var decibels: Float = -120.0
        if let recorder = recorder {
            recorder.updateMeters()
            decibels = recorder.averagePower(forChannel: 0)
        }
        return decibels
    }

    func initRecorder(completion: @escaping (Error?) -> Void) {
        if recordingSession!.recordPermission() == .granted {
            setupRecorder(completion: completion)
        } else {
            recordingSession.requestRecordPermission { [unowned self] allowed in
                if allowed {
                    self.setupRecorder(completion: completion)
                } else {
                    print("err")
                    completion((AVAudioSessionErrorCode.codeUnspecified as! Error))
                }
            }
        }
    }

    func closeRecorder() {
        recorder.stop()
        recorder.deleteRecording()
        try! recordingSession.setActive(false)
    }
}
