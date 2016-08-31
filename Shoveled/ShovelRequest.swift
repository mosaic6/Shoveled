//
//  ShovelRequest.swift
//  Shoveled
//
//  Created by Joshua Walsh on 3/1/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ShovelRequest: NSObject {
    var address: String
    var latitude: NSNumber
    var longitude: NSNumber
    var details: String
    var addedByUser: String
    var otherInfo: String
    var price: NSNumber
    var completed: Bool
    var accepted: Bool
    
    init(address: String, addedByUser: String, completed: Bool, accepted: Bool, latitude: NSNumber, longitude: NSNumber, details: String, otherInfo: String, price: NSNumber) {
        self.address = address
        self.addedByUser = addedByUser
        self.completed = completed
        self.accepted = accepted
        self.latitude = latitude
        self.longitude = longitude
        self.details = details
        self.otherInfo = otherInfo
        self.price = price
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "address": address,
            "details": details,
            "addedByUser": addedByUser,
            "latitude": latitude,
            "longitude": longitude,
            "otherInfo": otherInfo,
            "price": price,
            "completed": completed,
            "accepted": accepted
        ]
    }
    convenience override init() {
        self.init(address: "", addedByUser: "", completed: false, accepted: false, latitude: 0, longitude: 0, details: "", otherInfo: "", price: 0.0)
    }
}
