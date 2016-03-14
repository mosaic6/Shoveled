//
//  CustomButton.swift
//  Shoveled
//
//  Created by Joshua Walsh on 11/1/15.
//  Copyright © 2015 Lucky Penguin. All rights reserved.
//

import Foundation
import UIKit

class ShoveledButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = 5.0
        self.backgroundColor = UIColor(red: 78.0/255.0, green: 168.0/255.0, blue: 177.0/255.0, alpha: 1)
        self.tintColor = UIColor.whiteColor()
    }
}