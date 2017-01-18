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

        self.titleLabel?.text = ""
        self.layer.cornerRadius = 5.0
        self.tintColor = UIColor.white
    }
    
}
