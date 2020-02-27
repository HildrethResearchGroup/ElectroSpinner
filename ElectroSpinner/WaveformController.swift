//
//  WaveformController.swift
//  ElectroSpinner
//
//  Created by Owen Hildreth on 2/26/20.
//  Copyright © 2020 Hildreth Research Group. All rights reserved.
//

import Foundation

protocol WaveformController: class {
    var outputChannel: UInt {set get}
    static var minimumDelay: UInt32 { get }
    var waveformType: WaveformType {get set}
    
    var dispatchQueue: DispatchQueue { get }
    
    init?(identifier: String, outputChannel: UInt) throws
    
    func getIdentifier() throws -> String
    
    func setImpedence(_ impedenceSetting: ImpedenceSetting) throws
    
    func setVoltage(_ voltage: Double) throws
    
    func turnOne() throws
    
    func turnOff() throws
}



/**
   Use to set the impedence of the instrument
   - **standard**: Set the instrument's impedence to a standard 50Ω.  This is often used if you are driving a standard circuit.
   - **infinite**: Infinite Impedence is used when connecting directly to other high impedence instruments.  If this setting isn't used, then the high impedence instruments will see 2⨉ the desired voltage
   - **finite(UInt)**: Set impedence to an arbitrary postive value
   
    ### Usage Example: ###
    
    ````
    setImpedence(.infinite)
    
    setImpedence(.standard)
    
    setImpedence(.finite(250))
     ````
    
*/
enum ImpedenceSetting {
    /// Set the instrument's impedence to a standard 50Ω.  This is often used if you are driving a standard circuit.
    case standard

    /// Infinite Impedence is used when connecting directly to other high impedence instruments.  If this setting isn't used, then the high impedence instruments will see 2⨉ the desired volutage
    case infinite

    /// Set impedence to an arbitrary postive value
    case finite(UInt)
    
    /// Returns a VISA command string that can be used to set the Impedence of the instrument
    /// - Returns String: The VISA command to set the Impedence
    func command() -> String {
        switch self {
        case .standard:
            return "LOAD \(50)"
        case .infinite:
            return "LOAD INF"
        case let .finite(value):
            return "LOAD \(value)"
        }
    }
}

enum WaveformType {
    case DC
    
    func command() -> String {
        switch self {
        case .DC:
            return "WAVEFORM DC"
        }
    }
}
