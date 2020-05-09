//
//  PrintButton.swift
//  ElectroSpinner
//
//  Created by Owen Hildreth on 2/23/20.
//  Copyright © 2020 Hildreth Research Group. All rights reserved.
//

import Cocoa

//@IBDesignable
class PrintButton: NSButton {
    var delegate: PrintButtonDelegate? = nil
    var datasource: PrintButtonDataSource? = nil
    
    // MARK: State
    var status = PrintStatus.disabled {
        didSet {
            if status == .disabled {
                self.isEnabled = false
            } else {
                self.isEnabled = true
            }
            self.needsDisplay = true
        }
    }
    
    // MARK: Colors
    let color_disabled = NSColor.red
    let color_readyForPrinting = NSColor.green
    let color_printing = NSColor.orange
    //let color_finishedPrinting = NSColor.orange
    let color_error = NSColor.red
    
    
    // MARK: User Interactions
    override func mouseDown(with event: NSEvent) {
        print(self.status)
        //if self.status == .disabled {return}
        
        self.delegate?.printButtonDown(sender: self)
        if let datasourceStatus = self.datasource?.printButtonStatus(sender: self) {
            self.status = datasourceStatus
        } else {self.status = .disabled }
    }
    
    
    
    override func mouseUp(with event: NSEvent) {
        //if self.status == .disabled {return}
        self.delegate?.printButtonUp(sender: self)
        if let datasourceStatus = self.datasource?.printButtonStatus(sender: self) {
            self.status = datasourceStatus
        } else {self.status = .disabled }
    }

}


// MARK: - Drawing
extension PrintButton {
    
    private func getFillColor() -> NSColor {
        switch self.status {
        case .disabled, .notConnected: return color_disabled
        case .readyForPrinting: return color_readyForPrinting
        case .printing: return color_printing
        case .error: return color_error
        }
    }
    
    
    /// Make the stroke color slightly darker than the fill color
    private func getStrokeColor() -> NSColor {
        let fillColor = self.getFillColor()
        let percentage:CGFloat = 30/100
        var red = fillColor.redComponent
        var green = fillColor.greenComponent
        var blue = fillColor.blueComponent
        let alpha = fillColor.alphaComponent

        red = min(red - percentage, 1.0)
        green = min(green - percentage, 1.0)
        blue = min(blue - percentage, 1.0)
        
        let strokeColor = NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
        
        return strokeColor
    }
    
    override func draw(_ dirtyRect: NSRect) {
        // Fill the background with white
        //NSColor.white.setFill()
        //dirtyRect.fill()
        
        let sframe = self.bounds
        
        let ovalRect = NSMakeRect(sframe.minX + 2, sframe.minY + 2, sframe.width - 4, sframe.height - 4)
        
        let ovalPath = NSBezierPath(ovalIn: ovalRect)
        let fillColor = self.getFillColor()
        let strokeColor = self.getStrokeColor()
        fillColor.setFill()
        ovalPath.fill()
        strokeColor.setStroke()
        ovalPath.lineWidth = 1.5
        ovalPath.stroke()
    }
    
}


// MARK: - Delegate Protocol
protocol PrintButtonDelegate: AnyObject {
    func printButtonDown(sender: PrintButton)
    func printButtonUp(sender: PrintButton)
}


// MARK: - DataSource Protocol
protocol PrintButtonDataSource: AnyObject {
     func printButtonStatus(sender: PrintButton) -> PrintStatus
}





