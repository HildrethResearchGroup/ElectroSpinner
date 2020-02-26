//
//  ElectroSpinnerController.swift
//  ElectroSpinner
//
//  Created by Owen Hildreth on 2/23/20.
//  Copyright © 2020 Hildreth Research Group. All rights reserved.
//

import Foundation
import SwiftVISA

class ElectroSpinnerController {
    // MARK: Input Variables
    var electrospinnerVoltage = 0.0
    let amplifierGain = 1000.0
    var printTime = 0.0
   

    
    // MARK: Print Status Variables
    var startPrintTime: DispatchTime? = nil
    var safetyTriggerEnabled = false
    var connected = false
    var printing = false
    var error = false
    
    
    
    
    func printStatus() -> PrintStatus {
        if safetyTriggerEnabled == false {return .disabled}
        if error == true {return .error}
        if printing == true {return .printing}
        
        
        
        return .disabled
    }
    
    
    func elapsedTime() -> Double {
        if startPrintTime == nil {
            return 0.0
        }
        
        return 0.0
    }
    
}



// MARK: - Waveform Functions

extension ElectroSpinnerController {
    
}


// MARK: - Printing
extension ElectroSpinnerController {

    func canStartPrinting() -> Bool {
        let printStatus = self.printStatus()
        
        switch printStatus {
        case .readyForPrinting:
            return true
        default:
            return false
        }
    }
    
    
    func startPrinting() throws {
        let canStartWaveform = self.canStartPrinting()
        if canStartWaveform == false {
            let printStatus = self.printStatus()
            switch printStatus {
            case .disabled:
                throw startPrintingError.disabled
            case .notConnected:
                throw startPrintingError.notConnected
            case .printing:
                throw startPrintingError.alreadyRunning
            default:
                throw startPrintingError.error
            }
        }
        
        
        
        self.printing = true
        // Stop the waveform
        let delayTime = DispatchTime.now() + printTime
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
            self.stopPrinting()
        })
            
    }
        
        

    func stopPrinting() {
        print("Test")
        self.startPrintTime = nil
        self.printing = false
    }
    
}



// MARK: Enums
enum startPrintingError: Error {
    case alreadyRunning
    case disabled
    case notConnected
    case error
}



enum PrintStatus:Int {
    case disabled = 1
    case notConnected
    case enabled
    case readyForPrinting
    case printing
    case finishedPrinting
    case error
}

