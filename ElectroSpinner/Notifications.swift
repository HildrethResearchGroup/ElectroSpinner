//
//  Notifications.swift
//  ElectroSpinner
//
//  Created by Owen Hildreth on 3/7/20.
//  Copyright © 2020 Hildreth Research Group. All rights reserved.
//

import Foundation



extension NSNotification.Name {
    // Notifications that are inputs of printStatus
    static let safetyStatusDidChange = NSNotification.Name("safetyStatusDidChange")
    static let connectionStatusDidChange = NSNotification.Name("connectionStatusDidChange")
    static let dcWaveformGeneratorStatusDidChange = NSNotification.Name("dcWaveformGeneratorStatusDidChange")
    
    // Notifications that are Outputs of PrintStatus
    static let printStatusDidChange = NSNotification.Name("printStatusDidChange")
}

// MARK: Strings for Keys

let printStatusKey = "printStatusKey"
let dcWaveformGeneratorStatusKey = "dcWaveformGeneratorStatusKey"

