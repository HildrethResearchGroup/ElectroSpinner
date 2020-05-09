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
                printStatusDataModel.dcWaveformGeneratorStatus = .connected
            } else {printStatusDataModel.dcWaveformGeneratorStatus = .notConnected}
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
        
        waveformController?.voltage = waveformVoltage
        
        try waveformController?.runWaveform(for: printTime)
    }
        
        
    func stopPrinting() {
        waveformController?.stopWaveform()
        printStatusDataModel.startPrintTime = nil
    }
    
    
    
    func elapsedTime() -> Double {
        if printStatusDataModel.startPrintTime == nil {
            return 0.0
        }
        return 0.0
    }
}

// MARK: - PrintButtonDelegate
extension ElectroSpinnerController: PrintButtonDelegate {
    func printButtonDown(sender: PrintButton) {
        print("printButtonDown")
        // Get print status
        let status = printStatusDataModel.printStatus
        
        switch status {
        case .readyForPrinting:
             print("starting Print")
                   do {
                       try self.startPrinting()
                   } catch {
                       print("Error when trying to print")
                       print("Error")
                   }
        case .printing:
            print("Stopping Print")
            self.stopPrinting()
        case .disabled, .error, .notConnected:
            return
        }

    }
    
    func printButtonUp(sender: PrintButton) {
        print("printButtonUp")
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

