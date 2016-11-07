//
//  StripeAPI.swift
//  Shoveled
//
//  Created by Joshua Walsh on 7/13/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation
import Stripe

let testAuthKey = "Bearer sk_test_PbH5UZ20DwkBVbf6qWeOHSfh"
//let prodAuthKey =

private let API_POST_CUSTOMER = "https://api.stripe.com/v1/customers"
private let API_GET_CUSTOMERS = "https://api.stripe.com/v1/customers"
private let API_POST_CHARGE   = "https://api.stripe.com/v1/charges"
private let API_GET_CONNECTED_ACCOUNTS = "https://api.stripe.com/v1/accounts"

class StripeAPI {
    
    static let sharedInstance = StripeAPI()
    
    // Get customers with Stripe account
    func getCustomers(_ completion: @escaping (_ result: NSDictionary?, _ error: NSError?) -> ()) {
        let sessionConfig = URLSessionConfiguration.default        
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        guard let URL = URL(string: API_GET_CUSTOMERS) else { return }
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        
        request.addValue(testAuthKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let semaphore = DispatchSemaphore(value: 0)
        /* Start a new Task */
        let task = session.dataTask(with: URL, completionHandler: {
            (data, response, error) in
            
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                
                var parsedObject: [String: Any]?
                var serializationError: NSError?
                
                if statusCode == 200 {
                    print("URL Session Task Succeeded: HTTP \(statusCode)")
                    
                    if let data = data {
                        do {
                            parsedObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: Any]
                            
                        } catch let error as NSError {
                            serializationError = error
                            parsedObject = nil
                        } catch {
                            fatalError()
                        }
                    }
                    completion(parsedObject as NSDictionary?, serializationError)
                    semaphore.signal()
                }
                
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
        })
        task.resume()
    }
    
    // Create a new customer if they don't already exist
    func createCustomerStripeAccountWith(_ customerDesciption: String = "Shoveled Customer", source: String, email: String, completion: @escaping (_ success: Bool, _ error: NSError?) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        /* Create the Request:
         POST Customers (POST https://api.stripe.com/v1/customers)
         */
        
        guard let URL = URL(string: API_POST_CUSTOMER) else {return}
        let request = NSMutableURLRequest(url: URL)
        request.httpMethod = "POST"
        
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
        request.httpBody = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: true)
        
        /* Start a new Task */
        let task = session.dataTask(with: URL, completionHandler: {
            (data, response, error) in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                
                if statusCode == 200 {
                    completion(true, nil)
                }
            }
            else {
                // Failure
                completion(false, error as NSError?)
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
        })
        task.resume()
    }
    
    // Send the charge to Stripe
    func sendChargeToStripeWith(_ amount: String, source: String, description: String, completion: @escaping (_ success: Bool, _ error: NSError?) -> ()) {
        
        guard let URL = URL(string: API_POST_CHARGE) else {return}
        let request = NSMutableURLRequest(url: URL)
        request.httpMethod = "POST"
        
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
        request.httpBody = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: true)
        
        /* Start a new Task */
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                if statusCode == 200 {
                    print("Payment Successful \(statusCode)")
                    completion(true, nil)
                }
                else {
                    print(response)
                }
            }
            else {
                // Failure
                completion(false, error as NSError?)
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
        })
        task.resume()        
    }
    
    func getConnectedAccounts() -> NSArray {
        
        var dataArray: NSArray = []
        
        let URL = NSURL(string: API_GET_CONNECTED_ACCOUNTS)
        var request = URLRequest(url: URL as! URL)
        request.httpMethod = "GET"
        
        // Headers
        request.addValue("stripe.csrf=lF5XxRqmAOvjwiLkJBd4Pfli9f97ZU2q5MxeFyPaJPA3u4sUDjSMTu3O2PqRkJZ5rTANI6sA2PAHhmQxSSpEsA%3D%3D", forHTTPHeaderField: "Cookie")
        request.addValue(testAuthKey, forHTTPHeaderField: "Authorization")
        
        let semaphore = DispatchSemaphore(value: 0)
        /* Start a new Task */
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) in
            if (error == nil) {
                // Success
                var parsedObject: [String: AnyObject]?
                var serializationError: NSError?
                
                let statusCode = (response as! HTTPURLResponse).statusCode
                if statusCode == 200 {
                    print("URL Session Task Succeeded: HTTP \(statusCode)")
                    
                    if let data = data {
                        do {
                            parsedObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject]
                            
                            if let object = parsedObject {
                                dataArray = (object["data"] as? NSArray)!
                                print(dataArray)
                            }
                        } catch let error as NSError {
                            serializationError = error
                            parsedObject = nil
                        } catch {
                            fatalError()
                        }
                    }
                    semaphore.signal()
                }
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
        })
        task.resume()
        
        return dataArray as NSArray
    }
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary: URLQueryParameterStringConvertible {
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
                                String(describing: key).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!,
                                String(describing: value).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}

extension URL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new NSURL.
     */
    func URLByAppendingQueryParameters(_ parametersDictionary: Dictionary<String, String>) -> URL {
        let URLString: NSString = NSString(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString as String)!
    }
}
