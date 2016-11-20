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
    var status: String
    var id: String
    var createdAt: String
    var acceptedByUser: String
    var stripeChargeToken: String

    init(address: String, addedByUser: String, status: String, latitude: NSNumber, longitude: NSNumber, details: String, otherInfo: String, price: NSNumber, id: String, createdAt: String, acceptedByUser: String, stripeChargeToken: String) {
        self.address = address
        self.addedByUser = addedByUser
        self.status = status
        self.latitude = latitude
        self.longitude = longitude
        self.details = details
        self.otherInfo = otherInfo
        self.price = price
        self.id = id
        self.createdAt = createdAt
        self.acceptedByUser = acceptedByUser
        self.stripeChargeToken = stripeChargeToken
    }

    func toAnyObject() -> NSDictionary {
        return [
            "address": address,
            "details": details,
            "addedByUser": addedByUser,
            "latitude": latitude,
            "longitude": longitude,
            "otherInfo": otherInfo,
            "price": price,
            "status": status,
            "id": id,
            "createdAt": createdAt,
            "acceptedByUser": acceptedByUser,
            "stripeChargeToken": stripeChargeToken
        ]
    }
    convenience override init() {
        self.init(address: "",
                  addedByUser: "",
                  status: "",
                  latitude: 0,
                  longitude: 0,
                  details: "",
                  otherInfo: "",
                  price: 0.0,
                  id: "",
                  createdAt: "",
                  acceptedByUser: "",
                  stripeChargeToken: "")
    }
}
