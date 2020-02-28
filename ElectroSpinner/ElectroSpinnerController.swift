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
    var electrospinnerVoltage = 0.0 {
        didSet {
            let waveformVoltage = electrospinnerVoltage/amplifierGain
            waveformController?.voltage = waveformVoltage
        }
    }
    let amplifierGain = 1000.0
    var printTime = 0.0
   
    
    // MARK: Wavefunction Controller
    var waveformController: DCWaveformController?
    
    // MARK: Print Status Variables
    var startPrintTime: DispatchTime? = nil
    var safetyTriggerEnabled = false
    var connected = false
    var printing = false
    var error = false
     
}



// MARK: - Waveform Controller
extension ElectroSpinnerController {
    func makeWaveFormController() throws -> DCWaveformController? {
        let identifier = "USB0::0x0957::0x2607::MY52200879::INSTR"
        let outputChannel: UInt = 1
        return try DCWaveformController(identifier: identifier, outputChannel: outputChannel)
    }

    func connectToWaveformGenerator() throws {
        try self.waveformController = self.makeWaveFormController()
    }
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
        // Check to see if printing is allowed.  Return error if printing can't be done.
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
        
        
        try waveformController?.turnOn()
        try waveformController?.runWaveform(for: printTime)
        
        self.printing = true
    }
        
        

    func stopPrinting() {
        print("Test")
        do {
            try waveformController?.stopWaveform()
        } catch {print(error)}
        
        self.startPrintTime = nil
        self.printing = false
    }
    
    
    func printStatus() -> PrintStatus {
        if safetyTriggerEnabled == false {return .disabled}
        if error == true {return .error}
        if printing == true {return .printing}
        
        
        // TODO: Fix printStatus
        return .enabled
    }
    
    
    func elapsedTime() -> Double {
        if startPrintTime == nil {
            return 0.0
        }
        
        return 0.0
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

