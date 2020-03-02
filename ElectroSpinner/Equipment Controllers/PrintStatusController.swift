//
//  PrintStatusController.swift
//  ElectroSpinner
//
//  Created by Owen Hildreth on 3/1/20.
//  Copyright © 2020 Hildreth Research Group. All rights reserved.
//

import Foundation

class PrintStatusController {
    var delegate: PrintStatusControllerDelegate?
    
    // MARK: State Variables
    var printButtonState = false {
        didSet {printStatus = self.determinePrintStatus() } }
    var safetyKeyState = false {
        didSet {printStatus = self.determinePrintStatus() } }
    var connectedState = false {
        didSet {printStatus = self.determinePrintStatus() } }
    var printingState = false {
        didSet {printStatus = self.determinePrintStatus() } }
    // TODO: Need to implement errorState logic
    var errorState = false {
        didSet {printStatus = self.determinePrintStatus() } }
    
    // MARK: Print Status Variables
    var printStatus = PrintStatus.disabled {
        didSet {
            if printStatus != oldValue {
                delegate?.printStatusDidUpdate(updatedPrintStatus: printStatus)
            }
        }
    }
    
    var startPrintTime: DispatchTime? = nil
    
    
    func determinePrintStatus() -> PrintStatus {
        if safetyKeyState == false {return .disabled}
        if connectedState == false {return .notConnected}
        if errorState == true {return .error}
        if printingState == true {return .printing}
              
        return .readyForPrinting
    }
}

protocol PrintStatusControllerDelegate {
    func printStatusDidUpdate(updatedPrintStatus: PrintStatus)
}


// MARK: - PrintButtonDelegate
extension PrintStatusController: PrintButtonDelegate {
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

// MARK: - ElectroSpinnerViewDelegate
extension PrintStatusController: ElectroSpinnerViewDelegate {
    func userSafetyKeyDown(sender: ElectroSpinnerView) {
        print("userSafetyKeyDown")
        //electrospinnerController.safetyKeyState = true
    }
    
    func userSafetyKeyUp(sender: ElectroSpinnerView) {
        print("userSafetyKeyUp")
        //electrospinnerController.safetyKeyState = false
    }
}
