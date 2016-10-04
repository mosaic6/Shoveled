//
//  CompleteRequestView.swift
//  Shoveled
//
//  Created by Joshua Walsh on 9/19/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation
import UIKit

class CompleteRequestView: UIView {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addCompleteRequestView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(codeer: has not been implemented")
    }
    
    func addCompleteRequestView() {
        self.backgroundColor = UIColor(red: 230.0 / 255.0, green: 230.0 / 255.0, blue: 220.0 / 255.0, alpha: 1.0)
        self.layer.cornerRadius = 5.0
    }
}
