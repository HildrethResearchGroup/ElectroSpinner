//
//  PrintStatusDataModel.swift
//  ElectroSpinner
//
//  Created by Owen Hildreth on 3/1/20.
//  Copyright © 2020 Hildreth Research Group. All rights reserved.
//

import Foundation

// MARK: Status Ehums
enum EquipmentStatus {
    case notConnected
    case connected
    case inUse
}

enum PrintStatus:Int {
    case notConnected
    case disabled
    case readyForPrinting
    case printing
    case error
}

/**
 Data model that either holds or accesses the statespace of the electrospinner
 */
class PrintStatusDataModel {
    // Status of the DCWaveformGenerator.  Default is to be notConnected
    var dcWaveformGeneratorStatus = EquipmentStatus.notConnected {
        didSet {
            if dcWaveformGeneratorStatus != oldValue {
                self.printStatus = determinePrintStatus()
                let notification = Notification(name: .dcWaveformGeneratorStatusDidChange, object: self, userInfo: [dcWaveformGeneratorStatusDidChangeKey : dcWaveformGeneratorStatus])
                NotificationCenter.default.post(notification)
            }
        }
    }
    
    // MARK: State Variables
    // Status of the safetyState varible.  This variable isn't currently used since the electrospinner is in an enclosed glove box.  As a result, the safetyState is currently set to "true" with no code implemented to change it.
    private var safetyState = true {
        didSet {printStatus = self.determinePrintStatus() } }

    // TODO: Need to implement errorState logic
    private var errorState = false {
        didSet {printStatus = self.determinePrintStatus() } }
    
    // MARK: Print Status Variables
    var printStatus = PrintStatus.disabled {
        didSet {
            if printStatus != oldValue {
                let notification = Notification(name: .printStatusDidChange, object: self, userInfo: [printStatusDidChangeKey: printStatus])
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
        
        if let equipmentStatus = userInfo?[dcWaveformGeneratorStatusDidChangeKey] as? EquipmentStatus {
            dcWaveformGeneratorStatus = equipmentStatus
        }
    }
        
}





