//
//  StripeAPI.swift
//  Shoveled
//
//  Created by Joshua Walsh on 7/13/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation
import Stripe

let testAuthKey = "Basic c2tfdGVzdF9QYkg1VVoyMER3a0JWYmY2cVdlT0hTZmg6OioqKioqIEhpZGRlbiBjcmVkZW50aWFscyAqKioqKg=="
//let prodAuthKey =

let API_POST_CUSTOMER = "https://api.stripe.com/v1/customers"
let API_GET_CUSTOMERS = "https://api.stripe.com/v1/customers"
let API_POST_CHARGE   = "https://api.stripe.com/v1/charges"

class StripeAPI {
    
    static let sharedInstance = StripeAPI()
    
    // Get customers with Stripe account
    func getCustomers(completion: (result: NSDictionary?, error: NSError?) -> Void) {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        /* Create the Request:
         GET Customers (GET https://api.stripe.com/v1/customers)
         */
        
        guard let URL = NSURL(string: API_GET_CUSTOMERS) else {return}
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "GET"
        
        // Headers
        
        request.addValue(testAuthKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        
        /* Start a new Task */
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                
                var parsedObject: AnyObject?
                var serializationError: NSError?
                
                if statusCode == 200 {
                    print("URL Session Task Succeeded: HTTP \(statusCode)")
                    
                    if let data = data {
                        do {
                            parsedObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                            
                        } catch let error as NSError {
                            serializationError = error
                            parsedObject = nil
                        } catch {
                            fatalError()
                        }
                    }
                    completion(result: parsedObject as? NSDictionary, error: serializationError)
                }
                
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    // Create a new customer if they don't already exist
    func createCustomerStripeAccountWith(customerDesciption: String = "Shoveled Customer", source: String, email: String) {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        /* Create the Request:
         POST Customers (POST https://api.stripe.com/v1/customers)
         */
        
        guard let URL = NSURL(string: API_POST_CUSTOMER) else {return}
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "POST"
        
        // Headers
        
        request.addValue(testAuthKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Form URL-Encoded Body
        
        let bodyParameters = [
            "email": email,
            "description": customerDesciption,
            "source": source,
            ]
        let bodyString = bodyParameters.queryParameters
        request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        /* Start a new Task */
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    
    // Send the charge to Stripe
    func sendChargeToStripeWith(amount: String, source: String, description: String) {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        /* Create the Request:
         Request (POST https://api.stripe.com/v1/charges)
         */
        
        guard let URL = NSURL(string: API_POST_CHARGE) else {return}
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "POST"
        
        // Headers
        
        request.addValue(testAuthKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Form URL-Encoded Body
        
        let bodyParameters = [
            "amount": amount,
            "currency": "usd",
            "source": source,
            "description": description,
            ]
        let bodyString = bodyParameters.queryParameters
        request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        /* Start a new Task */
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
     */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = NSString(format: "%@=%@",
                                String(key).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!,
                                String(value).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
            parts.append(part as String)
        }
        return parts.joinWithSeparator("&")
    }
    
}

extension NSURL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new NSURL.
     */
    func URLByAppendingQueryParameters(parametersDictionary : Dictionary<String, String>) -> NSURL {
        let URLString : NSString = NSString(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return NSURL(string: URLString as String)!
    }
}
