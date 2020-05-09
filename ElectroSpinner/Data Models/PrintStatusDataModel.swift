//
//  PrintStatusDataModel.swift
//  ElectroSpinner
//
//  Created by Owen Hildreth on 3/1/20.
//  Copyright © 2020 Hildreth Research Group. All rights reserved.
//

import Foundation

class PrintStatusDataModel {
    var delegate: PrintStatusDataModelDelegate?
    var dcWaveformGeneratorStatus = EquipmentStatus.notConnected {
        didSet {
            self.printStatus = determinePrintStatus()
        }
    }
    
    // MARK: State Variables
    /**
    var printButtonState: Bool {
        get {
            switch printStatus {
            case .printing, .readyForPrinting:
                return true
            case .notConnected, .disabled, .error:
                return false
            }
        }
    }
     */
    
    private var safetyState = true {
        didSet {printStatus = self.determinePrintStatus() } }

    // TODO: Need to implement errorState logic
    private var errorState = false {
        didSet {printStatus = self.determinePrintStatus() } }
    
    // MARK: Print Status Variables
    var printStatus = PrintStatus.disabled {
        didSet {
            if printStatus != oldValue {
                delegate?.printStatusDidUpdate(updatedPrintStatus: printStatus)
                let notification = Notification(name: .printStatusDidChange, object: self, userInfo: [printStatusKey: printStatus])
                NotificationCenter.default.post(notification)
                
            }
        }
    }
    
    var startPrintTime: DispatchTime? = nil
    
    
    // Mark: - Init
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatedcWaveformGeneratorStatus(_:)), name: .dcWaveformGeneratorStatusDidChange, object: nil)
    }
    
    // MARK: - Functions
    func determinePrintStatus() -> PrintStatus {
        if safetyState == false {return .disabled}
        if self.dcWaveformGeneratorStatus == .notConnected {return .disabled}
        if errorState == true {return .error}
        if self.dcWaveformGeneratorStatus == .inUse {return .printing}
              
        return .readyForPrinting
    }
    
    @objc func updatedcWaveformGeneratorStatus(_ notification: Notification) {
        let userInfo = notification.userInfo
        
        if let equipmentStatus = userInfo?[dcWaveformGeneratorStatusKey] as? EquipmentStatus {
            dcWaveformGeneratorStatus = equipmentStatus
        }
    }
        
}


// MARK: - PrintStatusDataModelDelegate
protocol PrintStatusDataModelDelegate {
    func printStatusDidUpdate(updatedPrintStatus: PrintStatus)
}









// MARK: - PrintButtonDataSource
extension PrintStatusDataModel: PrintButtonDataSource {
    
    func printButtonStatus(sender: PrintButton) -> PrintStatus {
        return printStatus
    }
}


// Refractoring to make ElectroSpinnerViewDelegate unneeded.
/**
// MARK: - ElectroSpinnerViewDelegate
extension PrintStatusDataModel: ElectroSpinnerViewDelegate {
    func userSafetyKeyDown(sender: ElectroSpinnerView) {
        print("userSafetyKeyDown")
        safetyState = true
    }
    
    func userSafetyKeyUp(sender: ElectroSpinnerView) {
        print("userSafetyKeyUp")
        safetyState = false
    }
}
 */
