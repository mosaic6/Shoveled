//
//  StripeManager.swift
//  Shoveled
//
//  Created by Joshua Walsh on 9/14/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation

class StripeManager {
    
    
    // Get Customers
    class func getCustomers(completion: (customerEmail: String) -> ()) {
        StripeAPI.sharedInstance.getCustomers { (result, error) in
            if let result = result {
                if let data = result.objectForKey("data") as? [NSDictionary] {
                    for customers in data {
                        if let email = customers.objectForKey("email") as? String {
                            completion(customerEmail: email)
                        }
                    }
                }
            }
        }
    }
    
    // Send charge to Stripe
    class func sendChargeToStripeWith(amount: String, source: String, description: String, completion: (success: Bool, error: NSError) -> ()) {
        
        StripeAPI.sharedInstance.sendChargeToStripeWith(amount, source: source, description: description) { (success, error) in
            if success {
                print("Credit Card was charged with token: \(source)")
            }
        }
    }
    
    // Create Customer 
    class func createCustomerStripeAccountWith(customerDesciption: String = "Shoveled Customer", source: String, email: String, completion: (success: Bool, error: NSError?) -> ()) {
        
        let error: NSError? = nil
        getCustomers { (customerEmail) in
            if email == customerEmail {
                completion(success: false, error: error)
            }
            else {
                completion(success: true, error: nil)
                StripeAPI.sharedInstance.createCustomerStripeAccountWith(customerDesciption, source: source, email: email) { (success, error) in
                    if success {
                        print("Customer Created!")
                    }
                }
            }            
        }
    }
}