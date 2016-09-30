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
        self.backgroundColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 220.0 / 255.0, alpha: 1.0)
        self.layer.cornerRadius = 5.0
        
        let takePhotoBtn = UIButton(type: .system)
        takePhotoBtn.frame = CGRect(x: self.bounds.size.width / 2, y: self.bounds.size.height - 20, width: 100, height: 60)
        takePhotoBtn.titleLabel?.textAlignment = NSTextAlignment.center
        takePhotoBtn.setTitle("Take Photo", for: UIControlState())
        takePhotoBtn.backgroundColor = UIColor(red: 220.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255, alpha: 1.0)
        takePhotoBtn.setNeedsDisplay()
        
        self.addSubview(takePhotoBtn)
        
    }
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        if let touch = touches.first {
//            let crosshairPos = touch.locationInView(self)
//            print("touch position: \(crosshairPos.x) \(crosshairPos.y)")
//            
//            self.layer.position = crosshairPos
//            
//            self.setNeedsDisplay()
//        }
//    }
}
