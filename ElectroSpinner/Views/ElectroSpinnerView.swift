//
//  ElextroSpinnerView.swift
//  ElectroSpinner
//
//  Created by Owen Hildreth on 2/29/20.
//  Copyright © 2020 Hildreth Research Group. All rights reserved.
//


import Cocoa

class ElectroSpinnerView: NSView {
    
    var safetyKeyState = false {
        didSet {
            if safetyKeyState == false {
                print("set safetyKeyState to false")
                delegate?.userSafetyKeyUp(sender: self)
            } else {
                print("set safetyKeyState to true")
                delegate?.userSafetyKeyDown(sender: self)
            }
        }
    }
    
    var delegate: ElectroSpinnerViewDelegate? = nil
    
    override var acceptsFirstResponder: Bool {
        return true
    }

    override func becomeFirstResponder() -> Bool {
        return true
    }

    override func resignFirstResponder() -> Bool {
        return true
    }
    
    override func keyDown(with event: NSEvent) {
        // Determine Key Event
        guard let character = event.characters else {return}
        if character == "s" {
            // Only send the delegate changes in keystate if state is changing
            if self.safetyKeyState == false {
                self.safetyKeyState = true
            }
        }
    }
    
    override func keyUp(with event: NSEvent) {
        // Determine Key Event
        guard let character = event.characters else {return}
        if character == "s" {
            // Only send the delegate changes in keystate if state is changing
            if self.safetyKeyState == true {
                self.safetyKeyState = false
            }
        }
    }
}




protocol ElectroSpinnerViewDelegate {
    func userSafetyKeyDown(sender: ElectroSpinnerView)
    func userSafetyKeyUp(sender: ElectroSpinnerView)
}
