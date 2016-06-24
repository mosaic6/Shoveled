//
//  ShovelRequest.swift
//  Shoveled
//
//  Created by Joshua Walsh on 3/1/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation
import UIKit

class ShovelRequest: NSObject {
    var key: String!
    var address: String!
    var latitude: NSNumber!
    var longitude: NSNumber!
    var details: String!
    var addedByUser: String!
    var shovelTime: String!
    var price: NSNumber!
    var completed: Bool!
    var accepted: Bool!
    
    init(key: String = "", address: String, addedByUser: String, completed: Bool, accepted: Bool, latitude: NSNumber, longitude: NSNumber, details: String, shovelTime: String, price: NSNumber) {
        self.key = key
        self.address = address
        self.addedByUser = addedByUser
        self.completed = completed
        self.accepted = accepted
        self.latitude = latitude
        self.longitude = longitude
        self.details = details
        self.shovelTime = shovelTime
        self.price = price
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
            "completed": completed,
            "accepted": accepted
        ]
    }
    convenience override init() {
        self.init(key: "", address: "", addedByUser: "", completed: false, accepted: false, latitude: 0, longitude: 0, details: "", shovelTime: "", price: 0)
    }
}
