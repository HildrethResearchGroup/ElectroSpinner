//
//  ElectroSpinnerController.swift
//  ElectroSpinner
//
//  Created by Owen Hildreth on 2/23/20.
//  Copyright © 2020 Hildreth Research Group. All rights reserved.
//

import Foundation
//import SwiftVISA

class ElectroSpinnerController {
    var electrospinnerVoltage = 0.0
    
    
}


enum PrintStatus:Int {
    case disabled = 1
    case enabled
    case printing
    case finishedPrinting
    case error
}
