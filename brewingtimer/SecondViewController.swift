//
//  SecondViewController.swift
//  brewingtimer
//
//  Created by Hans-Wilhelm Warlo on 11/03/2018.
//  Copyright © 2018 Hans-Wilhelm Warlo. All rights reserved.
//

import UIKit

class SecondViewController: UITableViewController {
    @IBOutlet var decibel: UILabel!
    @IBOutlet var micSwitch: UISwitch!
    @IBOutlet var pauseLabel: UISwitch!
    @IBOutlet var sensitivitySlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        micSwitch.isOn = useMic
        pauseLabel.isOn = pauseBelowThreshold
        sensitivitySlider.setValue(threshold, animated: false)
        decibel.text = String(round(threshold / 2) * 2) + "db"
    }

    @IBAction func done(_: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func sensitivityChange(_ sender: UISlider) {
        decibel.text = String(round(sender.value / 2) * 2) + "db"
        threshold = sender.value
    }

    @IBAction func toggleMic(_ sender: UISwitch) {
        useMic = sender.isOn
    }

    @IBAction func togglePause(_ sender: UISwitch) {
        pauseBelowThreshold = sender.isOn
    }
}
