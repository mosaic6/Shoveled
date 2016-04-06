//
//  ShovelRequest.swift
//  Shoveled
//
//  Created by Joshua Walsh on 3/1/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation
import Firebase

struct ShovelRequest {
    let key: String!
    let address: String!
    let latitude: NSNumber!
    let longitude: NSNumber!
    let details: String!
    let addedByUser: String!
    let shovelTime: String!
    let price: String!
    var completed: Bool!
    let ref: Firebase?
    
    init(address: String, addedByUser: String, completed: Bool, latitude: NSNumber, longitude: NSNumber, details: String, shovelTime: String, price: String, key: String = "") {
        self.key = key
        self.address = address
        self.addedByUser = addedByUser
        self.completed = completed
        self.latitude = latitude
        self.longitude = longitude
        self.details = details
        self.shovelTime = shovelTime
        self.price = price
        self.ref = nil
        
    }
    
    init(snapshot: FDataSnapshot) {
        key = snapshot.key
        address = snapshot.value["address"] as! String
        latitude = snapshot.value["latitude"] as! NSNumber
        longitude = snapshot.value["longitude"] as! NSNumber
        details = snapshot.value["details"] as! String
        addedByUser = snapshot.value["addedByUser"] as! String
        shovelTime = snapshot.value["shovelTime"] as! String
        price = snapshot.value["price"] as! String
        completed = snapshot.value["completed"] as! Bool
        ref = snapshot.ref
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "address": address,
            "details": details,
            "addedByUser": addedByUser,
            "latitude": latitude,
            "longitude": longitude,
            "shovelTime": shovelTime,
            "price": price,
            "completed": completed
        ]
    }
    
}