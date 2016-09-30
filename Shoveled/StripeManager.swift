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
    class func getCustomers(_ completion: @escaping (_ customerEmail: String) -> ()) {
        StripeAPI.sharedInstance.getCustomers { (result, error) in
            if let result = result {
                if let data = result.object(forKey: "data") as? [NSDictionary] {
                    for customers in data {
                        if let email = customers.object(forKey: "email") as? String {
                            completion(email)
                        }
                    }
                }
            }
        }
    }
    
    // Send charge to Stripe
    class func sendChargeToStripeWith(_ amount: String, source: String, description: String, completion: (_ success: Bool, _ error: NSError) -> ()) {
        
        StripeAPI.sharedInstance.sendChargeToStripeWith(amount, source: source, description: description) { (success, error) in
            if success {
                print("Credit Card was charged with token: \(source)")
            }
        }
    }
    
    // Create Customer 
    class func createCustomerStripeAccountWith(_ customerDesciption: String = "Shoveled Customer", source: String, email: String, completion: @escaping (_ success: Bool, _ error: NSError?) -> ()) {
        
        let error: NSError? = nil
        getCustomers { (customerEmail) in
            if email == customerEmail {
                completion(false, error)
            }
            else {
                completion(true, nil)
                StripeAPI.sharedInstance.createCustomerStripeAccountWith(customerDesciption, source: source, email: email) { (success, error) in
                    if success {
                        print("Customer Created!")
                    }
                }
            }            
        }
    }
}
