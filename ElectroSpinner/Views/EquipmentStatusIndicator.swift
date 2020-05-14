//
//  StatusIndicator.swift
//  ElectroSpinner
//
//  Created by Owen Hildreth on 5/8/20.
//  Copyright © 2020 Hildreth Research Group. All rights reserved.
//

import Cocoa

class EquipmentStatusIndicator: NSView {
    let color_notConnected = NSColor.orange
    let color_connected = NSColor.green
    let color_inUse = NSColor.red
    
    var status: EquipmentStatus = .notConnected {
        didSet {
            self.needsDisplay = true
        }
    }
    
}


// MARK: - Drawing
extension EquipmentStatusIndicator {
    
    private func getFillColor() -> NSColor {
        switch self.status {
        case .notConnected: return color_notConnected
        case .connected: return color_connected
        case .inUse: return color_inUse
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
