//
//  WaveformController.swift
//  ElectroSpinner
//
//  Created by Owen Hildreth on 2/26/20.
//  Copyright © 2020 Hildreth Research Group. All rights reserved.
//

import Foundation
import SwiftVISA

class DefaultWaveformController: WaveformController {

    

    static var minimumDelay: UInt32 = 2_000_000
    private var instrument: MessageBasedInstrument
    var outputChannel: UInt
    var waveformType: WaveformType = .DC
    
    
    // MARK: - Dispatch queue
    
    var dispatchQueue: DispatchQueue {
        return instrument.dispatchQueue
    }
    
    
    // MARK: - Initializers
    required init?(identifier: String, outputChannel: UInt = 1) {
        guard let instrumentManager = InstrumentManager.default else { return nil }
        guard let instrument = try? instrumentManager.makeInstrument(identifier: identifier) as? MessageBasedInstrument else {
            return nil
        }
        
        self.instrument = instrument
        self.outputChannel = outputChannel
        turnOn()
        setImpedence(.infinite)
    }
    
    
    
    // MARK: - WaveformController Protocol
    func getIdentifier() throws -> String {
        return try instrument.query("*IDN?\n", as: String.self, decoder: StringDecoder())
    }
    
    
    /**
    Set the Impedence of the instrument
    
    - Parameter impedenceSetting: enum of the target impedence
    */
    func setImpedence(_ impedenceSetting: ImpedenceSetting) {
        let outputString = "OUTPUT\(outputChannel)"
        let impedenceString = impedenceSetting.command()
        do {
            try instrument.write(outputString + ":" + impedenceString)  // Example: OUTPUT1:LOAD INF""
        } catch {
            print(error)
        }
    }
    
    
    /**
    Set the Output Voltage of the instrument
    
    - Parameter voltage: The target output voltage
    */
    func setVoltage(_ voltage: Double) throws {
        do {
            try instrument.write("Source\(outputChannel):VOLTAGE:OFFSET \(voltage)")
        } catch { print(error)}
    }
    
    
    func turnOn() {
        do {
            let waveformCommand = self.waveformType.command()
            try instrument.write("OUTPUT\(outputChannel) ON")
            try instrument.write("Source\(outputChannel):\(waveformCommand)")
        } catch {print(error)}
    }
    
    
}


extension DefaultWaveformController {
    private struct StringDecoder: VISADecoder {
        func decode(_ string: String) throws -> String {
            var fixedString = string
            
            if string.hasPrefix("1`") {
                fixedString = String(string.dropFirst(2))
            }
            
            while fixedString.hasSuffix("\n") {
                fixedString = String(fixedString.dropLast())
            }
            
            return fixedString
        }
    }
}
