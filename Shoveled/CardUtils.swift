//
//  CardUtils.swift
//  Shoveled
//
//  Created by Joshua Walsh on 12/9/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation

extension String {
    
    var stringForCreditCardProcessing: String {
        return self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
    }
}

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}

extension Float {
    var stringValue: String {
        return (self as Float).stringValue
    }
}
