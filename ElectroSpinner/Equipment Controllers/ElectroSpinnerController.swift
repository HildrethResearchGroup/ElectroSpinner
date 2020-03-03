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
    let printStatusDataModel: PrintStatusDataModel
    
    
    init(_ withPrintStatusDataModel: PrintStatusDataModel) {
        printStatusDataModel = withPrintStatusDataModel
    }
    
    // MARK: Input Variables
    var electrospinnerVoltage = 0.0 {
        didSet {
            waveformController?.voltage = waveformVoltage
        }
    }
    var waveformVoltage: Double {
        get {return electrospinnerVoltage/amplifierGain }
    }
    
    let amplifierGain = 1000.0
    var printTime = 0.0
    
    // MARK: Wavefunction Controller
    var waveformController: DCWaveformController? {
        didSet {
            if let _ = waveformController {
                printStatusDataModel.connectedState = true
            } else {printStatusDataModel.connectedState = false}
        }
    }
    


    
    
     
}



// MARK: - Waveform Controller
extension ElectroSpinnerController {
    private func makeWaveFormController() throws -> DCWaveformController? {
        print("makeWaveFormController")
        let identifier = "USB0::0x0957::0x2607::MY52200879::INSTR"
        let outputChannel: UInt = 1
        
        // DCWaveformController(identifier: identifier, outputChannel: outputChannel)
        let controller = try DCWaveformController(identifier: identifier, outputChannel: outputChannel)
        
        return controller
    }

    func connectToWaveformGenerator() throws {
        print("connectToWaveformGenerator")
        try self.waveformController = self.makeWaveFormController()
        
        // Update state if waveform controller connected
        if let _ = waveformController {
            printStatusDataModel.connectedState = true
        } else { printStatusDataModel.connectedState = false }
    }
}


// MARK: - Printing
extension ElectroSpinnerController {

    func canStartPrinting() -> Bool {
        let printStatus = printStatusDataModel.determinePrintStatus()
        
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
            let printStatus = printStatusDataModel.determinePrintStatus()
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
        waveformController?.voltage = waveformVoltage
        try waveformController?.runWaveform(for: printTime)
        
        printStatusDataModel.printingState = true
    }
        
        

    func stopPrinting() {
        print("Test")
        do {
            try waveformController?.stopWaveform()
        } catch {print(error)}
        
        printStatusDataModel.startPrintTime = nil
        printStatusDataModel.printingState = false
    }
    
    

    
    
    func elapsedTime() -> Double {
        if printStatusDataModel.startPrintTime == nil {
            return 0.0
        }
        
        return 0.0
    }
    
}


// MARK: - PrintStatusDataModel Delegate
extension ElectroSpinnerController: PrintStatusDataModelDelegate {
    func printStatusDidUpdate(updatedPrintStatus: PrintStatus) {
        switch updatedPrintStatus {
        // Turn off the waveform generator if the printStatus indicates that the waveform should be off
        case .disabled, .notConnected, .error:
            do {
                try waveformController?.turnOff()
            } catch {
                print("Error when trying to set printStatus for ElectroSpinner controller")
                print(error) }
        default: return }
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
    case notConnected
    case disabled
    case readyForPrinting
    case printing
    case error
}

