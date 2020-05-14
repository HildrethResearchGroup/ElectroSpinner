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
    @IBOutlet weak var switch_print: NSSwitch!
    
    @IBOutlet weak var textField_setElectroSpinnerVoltage: NSTextField!
    @IBOutlet weak var label_waveformVoltage: NSTextField!
    
    @IBOutlet weak var textField_setRunTime: NSTextField!
    @IBOutlet weak var label_elapsedTime: NSTextField!
    
    // MARK: - Elapsed Time Variables
    private var timer = Timer()
    var isTimerRunning = false
    private var elapsedTime: Double? {
        didSet {
            guard let unwrappedElapsedTime = elapsedTime else {
                self.label_elapsedTime.stringValue = "0.0"
                return
            }
            self.label_elapsedTime.stringValue = String(unwrappedElapsedTime)
        }
    }
    
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
    }
    
    
    
    // Mark: - Initializing
    override func awakeFromNib() {
        // Set delegates
        setDelegates()
        
        // Update print button state
        updatePrintButtonState()
        
        // Set for Notifications
        setupNotifications()
        
        // Update views with default values
        setInitialValuesForTextfields()
    }
    
    func setDelegates() {
        textField_setElectroSpinnerVoltage.delegate = self
        textField_setRunTime.delegate = self
    }
    
    func setInitialValuesForTextfields() {
        textField_setRunTime.stringValue = String(electrospinnerController.printTime)
        textField_setElectroSpinnerVoltage.stringValue = String(electrospinnerController.electrospinnerVoltage)
        label_elapsedTime.stringValue = "0.0"
        label_waveformVoltage.stringValue = String(electrospinnerController.waveformVoltage)
    }
    
    
    // MARK: - IBActions
    @IBAction func connectToWaveformGenerator(_ sender: Any) {
        do {
            try electrospinnerController.connectToWaveformGenerator()
        } catch  {
            print("Failed to Connect to Waveform Generator")
            print(error)
        }
    }
    
    
    @IBAction func startOrStopPrinting(_ sender: Any) {
        print("START: startOrStopPrinting")
        let printStatus = self.printStatusDataModel.printStatus
        
        switch printStatus {
        case .disabled, .error, .notConnected:
            return
        case .readyForPrinting:
            do {
                try  self.electrospinnerController.startPrinting()
            } catch  {
                print("Error tyring to print")
                return
            }
        case .printing:
            self.electrospinnerController.stopPrinting()
            self.stopTimer()
            return
        }
        
        self.runTimer()
    }
    
    
    // MARK: - Elapsed Time
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: (#selector((self.updateElapsedTime))), userInfo: nil, repeats: true)
        self.isTimerRunning = true
    }
    
    func stopTimer() {
        timer.invalidate()
        self.elapsedTime = nil
        self.isTimerRunning = false
    }
    
    @objc func updateElapsedTime() {
        self.elapsedTime = self.electrospinnerController.elapsedTime()
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
                                               selector: #selector(dataModelStateDidChange(_:)),
                                               name: .dcWaveformGeneratorStatusDidChange,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(dataModelStateDidChange(_:)), name: .printStatusDidChange, object: nil)
    }
    
    
    @objc func dataModelStateDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {return}
        
        if let  equipmentStatus = userInfo[dcWaveformGeneratorStatusDidChangeKey] as? EquipmentStatus {
            self.dcWaveformGeneratorStatusIndicator.status = equipmentStatus
            self.updatePrintButtonState()
        }
        if let printStatus = userInfo[printStatusDidChangeKey] as? PrintStatus {
            self.updatePrintButtonState()
            if printStatus != .printing && isTimerRunning == true {
                self.stopTimer()
            }
        }
        
    }
    
    func updatePrintButtonState() {
        let status = self.printStatusDataModel.printStatus
        
        switch status {
        case .disabled, .error, .notConnected:
            self.switch_print.state = .off
            self.switch_print.isEnabled = false
        case .printing:
            self.switch_print.state = .on
            self.switch_print.isEnabled = true
        case .readyForPrinting:
            self.switch_print.state = .off
            self.switch_print.isEnabled = true
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

   





