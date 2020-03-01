//
//  WaveformController.swift
//  ElectroSpinner
//
//  Created by Owen Hildreth on 2/26/20.
//  Copyright © 2020 Hildreth Research Group. All rights reserved.
//

import Foundation
import SwiftVISA

class DCWaveformController: WaveformController {
    // MARK: - Properties
    static var minimumDelay: UInt32 = 2_000_000
    var voltage = 0.0 {
        didSet {
            do {
                try setVoltage(voltage)
            } catch {
                print("Error when trying to set voltage")
                print(error) } }
    }
    private let startupVoltage = 0.0
    private let turnedOffVoltage = 0.0
    private var instrument: MessageBasedInstrument
    var outputChannel: UInt
    var waveformType: WaveformType = .DC
    var impedence: ImpedenceSetting = .standard {
        didSet {
            do {
                try setImpedence(impedence)
            } catch {
                print("Error when trying to set Impedence")
                print(error) } }
    }
    
    
    // MARK: - Dispatch queue
    
    var dispatchQueue: DispatchQueue {
        return instrument.dispatchQueue
    }
    
    
    // MARK: - Initializers
    required init?(identifier: String, outputChannel: UInt = 1) throws {
        guard let instrumentManager = InstrumentManager.default else { return nil }
        guard let instrument = try? instrumentManager.makeInstrument(identifier: identifier) as? MessageBasedInstrument else {
            return nil
        }
        
        self.instrument = instrument
        self.outputChannel = outputChannel
        try turnOn()
        try setImpedence(self.impedence)
    }
}


// MARK: - WaveformController Protocol
extension DCWaveformController {
    func getIdentifier() throws -> String {
        return try instrument.query("*IDN?\n", as: String.self, decoder: StringDecoder())
    }
    
    
    /**
    Set the Impedence of the instrument
    
    - Parameter impedenceSetting: enum of the target impedence
    */
    func setImpedence(_ impedenceSetting: ImpedenceSetting) throws {
        let outputString = "OUTPUT\(outputChannel)"
        let impedenceString = impedenceSetting.command()
        let commandString = outputString + ":" + impedenceString
        try instrument.write(commandString)  // Example: OUTPUT1:LOAD INF""
    }
    
    
    /**
    Set the Output Voltage of the instrument
    
    - Parameter voltage: The target output voltage
    */
    func setVoltage(_ voltage: Double) throws {
        try instrument.write("Source\(outputChannel):VOLTAGE:OFFSET \(voltage)")
    }
    
    func setWaveform() throws {
        let waveformCommand = self.waveformType.command()
        try instrument.write("Source\(outputChannel):\(waveformCommand)")
    }
    
    
    func turnOn() throws {
        // Set the waveform (DC in this case)
        try setWaveform()
        // Turn on with 0.0 volts for safety
        try setVoltage(startupVoltage)

        try instrument.write("OUTPUT\(outputChannel) ON")

        /*
        do {
            let waveformCommand = self.waveformType.command()
            try instrument.write("OUTPUT\(outputChannel) ON")
            try instrument.write("Source\(outputChannel):\(waveformCommand)")
        } catch {print(error)}
         */
    }
    

    func turnOff() throws {
        try setVoltage(turnedOffVoltage)
        try instrument.write("OUTPUT\(outputChannel) OFF")
        /*
        do {
            try instrument.write("OUTPUT\(outputChannel) OFF")
        } catch {print(error)}
        */
    }
}

// MARK: - Running the Waveform
extension DCWaveformController  {
    func runWaveform(for runTime: Double) throws {
        // Rerun turnOn and setVoltage to make sure the system is definitely on an ready to run the waveform
        try turnOn()
        try setVoltage(voltage)
        
        // Make sure that the input runTime isn't negative
        if runTime < 0 {return}
        
        // Calculate the run time
        let runLength = DispatchTime.now() + Double(runTime)
        
        // Have stopWaveform run after runLength
        DispatchQueue.main.asyncAfter(deadline: runLength, execute: {
            try self.stopWaveform()
            } as! @convention(block) () -> Void)
    }
    
    func stopWaveform() throws {
        try instrument.write("OUTPUT\(outputChannel) OFF")
    }
}


// MARK: - Decoders
extension DCWaveformController {
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
