
//
//  MicrophoneController.swift
//  brewingtimer
//
//  Created by Hans-Wilhelm Warlo on 29/10/2018.
//  Copyright © 2018 Hans-Wilhelm Warlo. All rights reserved.
//

import AVFoundation

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

    func setupRecorder() -> AVAudioSessionErrorCode? {
        try! recordingSession.setCategory(AVAudioSessionCategoryRecord)
        try! recordingSession.setActive(true)
        recorder = try! AVAudioRecorder(
            url: getDocumentsDirectory(),
            settings: settings
        )
        recorder!.isMeteringEnabled = true
        if !recorder!.prepareToRecord() {
            return AVAudioSessionErrorCode.codeUnspecified
        }
        recorder.record()
        recorder.updateMeters()
        return nil
    }

    func getDecibels() -> Float {
        var decibels: Float = -120.0
        if let recorder = recorder {
            recorder.updateMeters()
            decibels = recorder.averagePower(forChannel: 0)
        }
        return decibels
    }

    func initRecorder(completion: @escaping (AVAudioSessionErrorCode?) -> Void) {
        if recordingSession!.recordPermission() == .granted {
            completion(setupRecorder())
        } else {
            recordingSession.requestRecordPermission { [unowned self] allowed in
                if allowed {
                    completion(self.setupRecorder())
                } else {
                    completion(AVAudioSessionErrorCode.codeMissingEntitlement)
                }
            }
        }
    }

    func closeRecorder() {
        recorder?.stop()
        recorder?.deleteRecording()
        try! recordingSession.setActive(false)
    }
}
