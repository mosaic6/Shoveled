//
//  AppConfiguration.swift
//  Shoveled
//
//  Created by Joshua Walsh on 4/18/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation

public class AppConfiguration {
    
    static let authKey = "sk_test_PbH5UZ20DwkBVbf6qWeOHSfh"
    
    private struct Bundle {
        static var prefix = NSBundle.mainBundle().objectForInfoDictionaryKey("merchant.com.mosaic6") as! String
    }
    
    struct UserActivity {
        static let payment = "\(Bundle.prefix).Shoveled.payment"
    }
    
    struct Merchant {
        static let identifier = "merchant.\(Bundle.prefix).Shoveled"
    }
}