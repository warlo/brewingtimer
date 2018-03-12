//
//  SecondInterfaceController.swift
//  brewingtimer WatchKit Extension
//
//  Created by Hans-Wilhelm Warlo on 27/02/2018.
//  Copyright © 2018 Hans-Wilhelm Warlo. All rights reserved.
//

import WatchKit
import AVFoundation
import Foundation


class SecondInterfaceController: WKInterfaceController {
    
    @IBOutlet var mic: WKInterfaceLabel!
    @IBOutlet var sensitivity: WKInterfaceSlider!
    @IBOutlet var sensitivityLabel: WKInterfaceLabel!
    @IBOutlet var decibel: WKInterfaceLabel!
    
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
    
    @IBAction func sensitivityChange(_ value: Float) {
        sensitivityLabel.setText("Sensitivity   " + String(value) + "db")
        threshold = value
    }
    
    @IBAction func toggleMic(_ value: Bool) {
        useMic = value
    }
    
    @IBAction func togglePause(_ value: Bool) {
        pauseBelowThreshold = value
    }
}

