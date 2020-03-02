//
//  ElectroSpinnerViewController.swift
//  ElectroSpinner
//
//  Created by Owen Hildreth on 2/25/20.
//  Copyright © 2020 Hildreth Research Group. All rights reserved.
//

import Cocoa

class ElectroSpinnerViewController: NSViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var electrospinnerView: ElectroSpinnerView!
    
    @IBOutlet weak var button_connectToWaveFormGenerator: NSButton!
    @IBOutlet weak var button_printButton: PrintButton!
    
    @IBOutlet weak var textField_setElectroSpinnerVoltage: NSTextField!
    @IBOutlet weak var label_waveformVoltage: NSTextField!
    
    @IBOutlet weak var textField_setRunTime: NSTextField!
    @IBOutlet weak var label_elapsedTime: NSTextField!
    
    // MARK: Electrospinner Controller
    let electrospinnerController = ElectroSpinnerController()
    
    // MARK: State Variables
    var safetyKeyState = false
    var printButtonState = false
    
    
    // Mark: - Initializing
    override func awakeFromNib() {
        setDelegates()
    }
    
    func setDelegates() {
        button_printButton.delegate = electrospinnerController
        electrospinnerView.delegate = self as? ElectroSpinnerViewDelegate
        textField_setElectroSpinnerVoltage.delegate = self as NSTextFieldDelegate
        textField_setRunTime.delegate = self as NSTextFieldDelegate
    }
    
    
    // MARK: - Responding to User Inputs
    @IBAction func connectToWaveformGenerator(_ sender: Any) {
        print("connectToWaveformGenerator - start")
        do {
            try electrospinnerController.connectToWaveformGenerator()
        } catch  {
            print("Failed to Connect to Waveform Generator")
            print(error)
        }
        print("connectToWaveformGenerator - end")
    }
    
    
    func setElectroSpinnerVoltage(_ voltage: Double) {
        // Make that the voltage has changed before setting.
        if voltage != electrospinnerController.electrospinnerVoltage {
            self.electrospinnerController.electrospinnerVoltage = voltage
            self.label_waveformVoltage.stringValue = String(electrospinnerController.waveformVoltage)
        }
    }
    
    func setElectroSpinnerRunTime(_ runTime: Double) {
        // Make sure the runTime has changed before changing
        if runTime != electrospinnerController.printTime {
            self.electrospinnerController.printTime = runTime
        }
    }
}


// MARK: - NSTextFieldDelegate
extension ElectroSpinnerViewController: NSTextFieldDelegate {
    
    // Montior textfields and update Electrospinner controller state
    func controlTextDidEndEditing(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else {return}
        if textField == textField_setElectroSpinnerVoltage {
            let electroSpinnerVoltage = textField.doubleValue
            self.setElectroSpinnerVoltage(electroSpinnerVoltage)
        }
        else if textField == textField_setRunTime {
            let runTime = textField.doubleValue
            self.setElectroSpinnerRunTime(runTime)
        }
    }
}





