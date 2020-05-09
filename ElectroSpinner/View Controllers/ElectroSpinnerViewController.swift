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
    
    @IBOutlet weak var dcWaveformGeneratorStatusIndicator: EquipmentStatusIndicator!
    
    @IBOutlet weak var button_connectToWaveFormGenerator: NSButton!
    @IBOutlet weak var button_printButton: PrintButton!
    
    @IBOutlet weak var textField_setElectroSpinnerVoltage: NSTextField!
    @IBOutlet weak var label_waveformVoltage: NSTextField!
    
    @IBOutlet weak var textField_setRunTime: NSTextField!
    @IBOutlet weak var label_elapsedTime: NSTextField!
    
    // MARK: - Electrospinner Controller
    let electrospinnerController: ElectroSpinnerController
    let printStatusDataModel: PrintStatusDataModel
    
    
    // MARK: - Initializers
    required init?(coder: NSCoder) {
        // Create the PrintStatusDataModel to control the print state
        printStatusDataModel = PrintStatusDataModel()
        
        // Create the ElectroSpinnerController and pass it the printStatusDataModel
        electrospinnerController = ElectroSpinnerController(printStatusDataModel)
        
        
        
        // Required call to super.init
        super.init(coder: coder)
        
        // Set for Notifications
        setupNotifications()
        
        
    }
    

    
    
    // Mark: - Initializing
    override func awakeFromNib() {
        setDelegates()
    }
    
    func setDelegates() {
        button_printButton.datasource = printStatusDataModel
        button_printButton.delegate = electrospinnerController
        //electrospinnerView.delegate = printStatusDataModel as ElectroSpinnerViewDelegate
        
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
    
    // MARK: - Notifications
    func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateDCEquipmentStatusIndicator(_:)),
                                               name: .dcWaveformGeneratorStatusDidChange,
                                               object: nil)
    }
    
    @objc func updateDCEquipmentStatusIndicator(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo else {return}
        guard let equipmentStatus = userInfo[dcWaveformGeneratorStatusKey] as? EquipmentStatus else {return}
        self.dcWaveformGeneratorStatusIndicator.status = equipmentStatus
    }
    
    @objc func updatePrintButtonStatus(_ notification: Notification) {
        self.button_printButton.status = self.printStatusDataModel.printStatus
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




// MARK: - PrintStatusDataModel Delegate
extension ElectroSpinnerViewController: PrintStatusDataModelDelegate {
    func printStatusDidUpdate(updatedPrintStatus: PrintStatus) {
        switch updatedPrintStatus {
        // Turn off the waveform generator if the printStatus indicates that the waveform should be off
        case .disabled, .notConnected, .error:
            electrospinnerController.waveformController?.stopWaveform()
        default: return }
    }
}


   





