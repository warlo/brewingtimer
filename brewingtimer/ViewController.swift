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

class ViewController: UIViewController, CommonController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var button: UIButton!
    @IBOutlet var decibel: UILabel!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var image: UIImageView!

    var microphone = MicrophoneController()
    var graph = GraphController()

    func getGraph() -> GraphController {
        return graph
    }

    func getMicrophone() -> MicrophoneController {
        return microphone
    }

    func getDimensions() -> (width: CGFloat, height: CGFloat, scale: CGFloat) {
        return (width: image.bounds.width, height: 150, scale: UIScreen.main.scale)
    }

    func loadFailUI() {
        timerLabel.text = "NO MIC"

        if useMic {
            let alertController = UIAlertController(title: "Microphone permission",
                                                    message: "The microphone permission was not authorized. Please enable it in Settings to continue.",
                                                    preferredStyle: .alert)

            let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
                if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(appSettings) { _ in }
                }
            }
            alertController.addAction(settingsAction)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
        }
    }

    func updateDecibelLabel(decibels: Float) {
        decibel.text = String(round(decibels)) + " db"
    }

    func updateTimerLabel(time: Double) {
        timerLabel.text = String(format: "%.02f", time)
    }

    func updateImage(image: UIImage) {
        self.image.image = image
    }

    func updateButtonText(text: String) {
        button.setTitle(text, for: .normal)
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

        NotificationCenter.default.addObserver(self, selector: #selector(onDisappearWrapper), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onAppearWrapper), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        onLoad()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func onAppearWrapper() {
        onAppear()
    }

    @objc func onDisappearWrapper() {
        onDisappear()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
