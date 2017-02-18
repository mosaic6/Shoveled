//
//  ShovelRequest.swift
//  Shoveled
//
//  Created by Joshua Walsh on 3/1/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation
import Firebase

let AddressKey = "address"
let LatitudeKey = "latitude"
let LongitudeKey = "longitude"
let DetailsKey = "details"
let AddedByUserKey = "addedByUser"
let OtherInfoKey = "otherInfo"
let PriceKey = "price"
let StatusKey = "status"
let CreatedAtKey = "createdAt"
let AcceptedByUserKey = "acceptedByUser"
let StripeChargeTokenKey = "stripeChargeToken"

struct ShovelRequest {
    var address: String
    var latitude: Double
    var longitude: Double
    var details: String
    var addedByUser: String
    var otherInfo: String
    var price: Float
    var status: String
    var createdAt: String
    var acceptedByUser: String
    var stripeChargeToken: String
    var firebaseReference: FIRDatabaseReference?

    init(address: String, addedByUser: String, status: String, latitude: Double, longitude: Double, details: String, otherInfo: String, price: Float, createdAt: String, acceptedByUser: String, stripeChargeToken: String) {
        self.address = address
        self.addedByUser = addedByUser
        self.status = status
        self.latitude = latitude
        self.longitude = longitude
        self.details = details
        self.otherInfo = otherInfo
        self.price = price
        self.createdAt = createdAt
        self.acceptedByUser = acceptedByUser
        self.stripeChargeToken = stripeChargeToken
        self.firebaseReference = nil
    }
    
    init(snapshot: FIRDataSnapshot?) {
        let snapshotValue = snapshot?.value as? [String: Any]
        self.address = snapshotValue?[AddressKey] as! String
        self.details = snapshotValue?[DetailsKey] as! String
        self.latitude = snapshotValue?[LatitudeKey] as! Double
        self.longitude = snapshotValue?[LongitudeKey] as! Double
        self.otherInfo = snapshotValue?[OtherInfoKey] as! String
        self.price = snapshotValue?[PriceKey] as! Float
        self.addedByUser = snapshotValue?[AddedByUserKey] as! String
        self.status = snapshotValue?[StatusKey] as! String
        self.createdAt = snapshotValue?[CreatedAtKey] as! String
        self.acceptedByUser = snapshotValue?[AcceptedByUserKey] as! String
        self.stripeChargeToken = snapshotValue?[StripeChargeTokenKey] as! String
        self.firebaseReference = snapshot?.ref
    }

    func toAnyObject() -> Any {
        return [
            AddressKey: self.address,
            DetailsKey: self.details,
            LatitudeKey: self.latitude,
            LongitudeKey: self.longitude,
            OtherInfoKey: self.otherInfo,
            PriceKey: self.price,
            StatusKey: self.status,
            CreatedAtKey: self.createdAt,
            AcceptedByUserKey: self.acceptedByUser,
            StripeChargeTokenKey: self.stripeChargeToken,
            AddedByUserKey: self.addedByUser
        ]
    }
}
