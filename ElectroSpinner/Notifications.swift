//
//  Notifications.swift
//  ElectroSpinner
//
//  Created by Owen Hildreth on 3/7/20.
//  Copyright © 2020 Hildreth Research Group. All rights reserved.
//

import Foundation



/// NSNotificatio.Name Extension to hold the namespace for Notifications
extension NSNotification.Name {
    // Notification that the safety lockout status did change
    static let safetyStatusDidChange = NSNotification.Name(safetyStatusDidChangeKey)
    
    // Notification that the state of the DCWaveform Generator has changed
    static let dcWaveformGeneratorStatusDidChange = NSNotification.Name(dcWaveformGeneratorStatusDidChangeKey)
    
    // Notifications the print status did change
    static let printStatusDidChange = NSNotification.Name(printStatusDidChangeKey)
}

// MARK: Strings to use for Notificaiton.Name and as the keys for Notification.userinfo
let safetyStatusDidChangeKey = "safetyStatusDidChangeKey"
let dcWaveformGeneratorStatusDidChangeKey = "dcWaveformGeneratorStatusDid"
let printStatusDidChangeKey = "printStatusDidChangeKey"



