//
//  ElectroSpinnerController.swift
//  ElectroSpinner
//
//  Created by Owen Hildreth on 2/23/20.
//  Copyright © 2020 Hildreth Research Group. All rights reserved.
//

import Foundation
//import SwiftVISA

class ElectroSpinnerController {
    var electrospinnerVoltage = 0.0
    let amplifierGain = 1000.0
    var printTime = 0.0
    var startPrintTime: DispatchTime? = nil
    
    
    let printStatusController = PrintStatusController()
    
    func canStartWaveform() -> Bool {
        let printStatus = printStatusController.printStatus()
        
        switch printStatus {
        case .readyForPrinting:
            return true
        default:
            return false
        }
    }
    
    func startWaveform() throws {
        let canStartWaveform = self.canStartWaveform()
        if canStartWaveform == false {
            let printStatus = printStatusController.printStatus()
            switch printStatus {
            case .disabled:
                throw StartWaveformError.disabled
            case .notConnected:
                throw StartWaveformError.notConnected
            case .printing:
                throw StartWaveformError.alreadyRunning
            default:
                throw StartWaveformError.error
            }
        }
        
        
        
    }
    
}

enum StartWaveformError: Error {
    case alreadyRunning
    case disabled
    case notConnected
    case error
}





