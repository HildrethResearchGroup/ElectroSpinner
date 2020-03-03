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
    let electrospinnerController: ElectroSpinnerController
    let printStatusDataModel: PrintStatusDataModel
    
    // MARK: State Variables
    var safetyKeyState = false
    var printButtonState = false
    
     
    required init?(coder: NSCoder) {
        printStatusDataModel = PrintStatusDataModel()
        electrospinnerController = ElectroSpinnerController(printStatusDataModel)
        super.init(coder: coder)
    }
    
    
    // Mark: - Initializing
    override func awakeFromNib() {
        setDelegates()
    }
    
    func setDelegates() {
        button_printButton.delegate = printStatusDataModel as PrintButtonDelegate
        electrospinnerView.delegate = printStatusDataModel as ElectroSpinnerViewDelegate
        
        textField_setElectroSpinnerVoltage.delegate = self as NSTextFieldDelegate
        textField_setRunTime.delegate = self as NSTextFieldDelegate
    }
    
    
    // MARK: - IBActions
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
    
    
    
    // MARK: - Communicating with the Electrospinner Controller
    func setElectroSpinnerVoltage(_ voltage: Double) {
        // Make that the voltage has changed before setting.
        if voltage != electrospinnerController.electrospinnerVoltage {
            
            // Set the voltage for the electrospinner controller
            self.electrospinnerController.electrospinnerVoltage = voltage
            
            // Update the waveformVoltage label
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






   





