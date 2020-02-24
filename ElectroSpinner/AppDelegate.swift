//
//  AppDelegate.swift
//  ElectroSpinner
//
//  Created by Owen Hildreth on 2/23/20.
//  Copyright © 2020 Hildreth Research Group. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var button_connectToWaveFormGenerator: NSButton!
    @IBOutlet weak var button_printButton: printButton!
    @IBOutlet weak var textField_setElectroSpinnerVoltage: NSTextField!
    @IBOutlet weak var label_waveformVoltage: NSTextField!
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

