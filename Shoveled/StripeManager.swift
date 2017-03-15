
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
    class func sendChargeToStripeWith(amount: String, source: String, description: String, completion: @escaping (_ chargeId: String, _ result: [String: Any]) -> ()) {
        var chargeId = ""
        StripeAPI.sharedInstance.sendChargeToStripeWith(amount, source: source, description: description, completion: { result, error
            in
            if let result = result {
                if let error = result["error"] as? [String: Any] {
                    completion("", error)
                    return
                }
                guard let id = result.object(forKey: "id") as? String else { return }
                chargeId = id
                completion(chargeId, [:])
            }
        })
    }

    // Create Customer 
    class func createCustomerStripeAccountWith(_ customerDesciption: String = "Shoveled Customer", source: String, email: String, completion: @escaping (_ success: Bool, _ error: NSError?) -> ()) {

        let error: NSError? = nil
        getCustomers { (customerEmail) in
            if email == customerEmail {
                completion(false, error)
            } else {
                completion(true, nil)
                StripeAPI.sharedInstance.createCustomerStripeAccountWith(customerDesciption, source: source, email: email) { (success, error) in
                    if success {
                        print("Customer Created!")
                    }
                }
            }
        }
    }

    // Create Managed Account
    class func createManagedAccount(firstName: String,
                                    lastName: String,
                                    address1: String,
                                    city: String,
                                    state: String,
                                    zip: String,
                                    dobDay: String,
                                    dobMonth: String,
                                    dobYear: String,
                                    fullSS: String,
                                    accountRoutingNumber: String,
                                    accountAccountNumber: String,
                                    completion: @escaping (_ result: NSDictionary?, _ error: NSError?) -> ()) {

        StripeAPI.sharedInstance.createManagedAccount(firstName: firstName,
                                                      lastName: lastName,
                                                      address1: address1,
                                                      city: city,
                                                      state: state,
                                                      zip: zip,
                                                      dobDay: dobDay,
                                                      dobMonth: dobMonth,
                                                      dobYear: dobYear,
                                                      fullSS: fullSS,
                                                      accountRoutingNumber: accountRoutingNumber,
                                                      accountAccountNumber: accountAccountNumber) { result, error in

            if let result = result {
                completion(result, nil)
            } else {
                completion(nil, error)
            }
        }
    }

    // Send Refund
    class func sendRefundToCharge(chargeId: String) {
        StripeAPI.sharedInstance.sendRefundToCharge(chargeId: chargeId)
    }

    // Send Tranfer whe job is completed
    class func transferFundsToAccount(amount: String, destination: String, chargeId: String) {
        StripeAPI.sharedInstance.transferFundsToAccount(amount: amount, destination: destination, chargeId: chargeId)
    }

    // GET Connected Accounts
    class func getConnectedAccounts(completion: @escaping (_ email: String) -> ()) {
        var userEmail = ""
        StripeAPI.sharedInstance.getConnectedAccounts { (result, error) in
            if let objects = result {
                for item in objects {
                    if let item = item as? [String: AnyObject] {
                        guard let email = item["email"] as? String else { return }
                        userEmail = email
                        completion(userEmail)
                    }
                }
            } else {
                completion("")
            }
        }
    }

    // Send Code to Auth User

    // Eventually have to pass a copmletion block with success
    class func passCodeToAuthAccount(code: String) {
        StripeAPI.sharedInstance.passCodeToAuthAccount(code: code)
    }
}
