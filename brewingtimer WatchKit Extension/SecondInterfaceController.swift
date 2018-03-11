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
        decibel.setText(String(value) + "db")
        threshold = value
    }
    
    @IBAction func toggleMic(_ value: Bool) {
        useMic = value
        decibel.setText(String(useMic))
    }
    
}

