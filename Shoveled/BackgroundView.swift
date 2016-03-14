//
//  BackgroundView.swift
//  Shoveled
//
//  Created by Joshua Walsh on 10/14/15.
//  Copyright © 2015 Lucky Penguin. All rights reserved.
//

import UIKit

class BackgroundView: UIView {
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        
        // Background View
        
        //// Color Declarations
        let lightGreen: UIColor = UIColor(red: 30.0/255.0, green: 150.0/255.0, blue: 220.0/255.0, alpha: 1.000)
        let snowWhite: UIColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.000)
        
        let context = UIGraphicsGetCurrentContext()
        
        //// Gradient Declarations
        let purpleGradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [lightGreen.CGColor, snowWhite.CGColor], [0, 1])
        
        //// Background Drawing
        let backgroundPath = UIBezierPath(rect: CGRectMake(0, 0, self.frame.width, self.frame.height))
        CGContextSaveGState(context)
        backgroundPath.addClip()
        CGContextDrawLinearGradient(context, purpleGradient,
            CGPointMake(160, 0),
            CGPointMake(100, 568),
            [(CGGradientDrawingOptions.DrawsBeforeStartLocation), (CGGradientDrawingOptions.DrawsAfterEndLocation)])
        CGContextRestoreGState(context)
        
    }
    
}