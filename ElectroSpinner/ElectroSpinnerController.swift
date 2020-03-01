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
    var waveformController: DCWaveformController? {
        didSet {
            if let _ = waveformController {
                self.connectedState = true
            } else {self.connectedState = false}
        }
    }
    
    // MARK: Print Status Variables
    var safetyKeyState = false
    var connectedState = false
    var printingState = false
    var errorState = false
    
    var startPrintTime: DispatchTime? = nil
     
}



// MARK: - Waveform Controller
extension ElectroSpinnerController {
    private func makeWaveFormController() throws -> DCWaveformController? {
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
                throw startPrintingError.alreadyPrinting
            default:
                throw startPrintingError.error
            }
        }
        
        
        try waveformController?.turnOn()
        try waveformController?.runWaveform(for: printTime)
        
        self.printingState = true
    }
        
        

    func stopPrinting() {
        print("Test")
        do {
            try waveformController?.stopWaveform()
        } catch {print(error)}
        
        self.startPrintTime = nil
        self.printingState = false
    }
    
    
    func printStatus() -> PrintStatus {
        if safetyKeyState == false {return .disabled}
        if connectedState == false {return .notConnected}
        if errorState == true {return .error}
        if printingState == true {return .printing}
              
        return .readyForPrinting
    }
    
    
    func elapsedTime() -> Double {
        if startPrintTime == nil {
            return 0.0
        }
        
        return 0.0
    }
    
}



// MARK: - Enums
enum startPrintingError: Error {
    case alreadyPrinting
    case disabled
    case notConnected
    case error
}


enum PrintStatus:Int {
    case disabled = 1
    case notConnected
    case readyForPrinting
    case printing
    case error
}


// MARK: - PrintButtonDelegate
extension ElectroSpinnerController: PrintButtonDelegate {
    func printButtonDown(sender: PrintButton) {
        print("printButtonDown")
    }
    
    func printButtonUp(sender: PrintButton) {
        print("printButtonUp")
    }
    
    func printButtonStatus(sender: PrintButton) -> PrintStatus {
        return .printing
    }
    
}
