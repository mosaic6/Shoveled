//
//  StripeManager.swift
//  Shoveled
//
//  Created by Joshua Walsh on 9/14/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation

class StripeManager {
    
    
    class func getCustomers(withId customerId: String, completion: (result: NSDictionary) -> ()) {
        
        StripeAPI.sharedInstance.getCustomers { (result, error) in
            print(result)
        }
    }
}