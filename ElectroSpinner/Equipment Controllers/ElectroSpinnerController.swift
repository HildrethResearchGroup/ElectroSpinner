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
            } else {
                printStatusDataModel.dcWaveformGeneratorStatus = .notConnected}
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
        guard let controller = try DCWaveformController(identifier: identifier, outputChannel: outputChannel) else {
            self.printStatusDataModel.dcWaveformGeneratorStatus = .notConnected
            return nil
        }
        
        self.printStatusDataModel.dcWaveformGeneratorStatus = .connected
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
                throw StartPrintingError.disabled
            case .notConnected:
                throw StartPrintingError.disabled
            case .printing:
                throw StartPrintingError.disabled
            default:
                throw StartPrintingError.disabled
            }
        }
        
        waveformController?.voltage = waveformVoltage
        
        try waveformController?.runWaveform(for: printTime)
        
        self.printStatusDataModel.printStatus = .printing
        
    }
        
        
    func stopPrinting() {
        waveformController?.stopWaveform()
        self.printStatusDataModel.printStatus = .readyForPrinting
        printStatusDataModel.startPrintTime = nil
    }
    
    
    
    func elapsedTime() -> Double {
        if printStatusDataModel.startPrintTime == nil {
            return 0.0
        }
        return 0.0
    }
}


// MARK: - Enums
enum StartPrintingError: Error {
    case alreadyPrinting
    case disabled
    case notConnected
    case error
}
