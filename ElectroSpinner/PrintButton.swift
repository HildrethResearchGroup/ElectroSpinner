//
//  PrintButton.swift
//  ElectroSpinner
//
//  Created by Owen Hildreth on 2/23/20.
//  Copyright © 2020 Hildreth Research Group. All rights reserved.
//

import Cocoa

//@IBDesignable
class printButton: NSView {
    let color_disabled = NSColor.lightGray
    let color_enabled = NSColor.green
    let color_printing = NSColor.yellow
    let color_finishedPrinting = NSColor.orange
    let color_error = NSColor.red
    
    var status = PrintStatus.enabled {
        didSet {
            self.needsDisplay = true
        }
    }

    
    let ovalRect = NSMakeRect(2, 2, 75, 75)
    
    private func getFillColor() -> NSColor {
        switch self.status {
        case .disabled, .notConnected: return color_disabled
        case .enabled, .readyForPrinting: return color_enabled
        case .printing: return color_printing
        case .finishedPrinting: return color_finishedPrinting
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
        
        
        let ovalPath = NSBezierPath(ovalIn: ovalRect)
        let fillColor = self.getFillColor()
        let strokeColor = self.getStrokeColor()
        fillColor.setFill()
        ovalPath.fill()
        strokeColor.setStroke()
        ovalPath.lineWidth = 1.5
        ovalPath.stroke()
        
        /**
        let ovalTextContent = NSString(string: "S")
        let ovalStyle = NSMutableParagraphStyle()
        ovalStyle.alignment = .center

        let ovalFontAttributes = [NSAttributedString.Key.font: NSFont(name: "HelveticaNeue", size: 23)!, NSAttributedString.Key.foregroundColor: NSColor.black, NSAttributedString.Key.paragraphStyle: ovalStyle]

        let ovalTextHeight: CGFloat = ovalTextContent.boundingRect(with: NSMakeSize(ovalRect.width, CGFloat.infinity), options: NSString.DrawingOptions.usesLineFragmentOrigin, attributes: ovalFontAttributes).size.height
        let ovalTextRect: NSRect = NSMakeRect(ovalRect.minX, ovalRect.minY + (ovalRect.height - ovalTextHeight) / 2, ovalRect.width, ovalTextHeight)
        NSGraphicsContext.saveGraphicsState()
        ovalTextContent.draw(in: NSOffsetRect(ovalTextRect, 0, 1), withAttributes: ovalFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
        */
        
    }
    
    
    
}





