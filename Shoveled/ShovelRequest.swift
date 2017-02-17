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
    
    static let AddressKey = "address"
    static let LatitudeKey = "latitude"
    static let LongitudeKey = "longitude"
    static let DetailsKey = "details"
    static let AddedByUserKey = "addedByUser"
    static let OtherInfoKey = "otherInfo"
    static let PriceKey = "price"
    static let StatusKey = "status"
    static let IdKey = "id"
    static let CreatedAtKey = "createdAt"
    static let AcceptedByUserKey = "acceptedByUser"
    static let StripeChargeTokenKey = "stripeChargeToken"
    
    var address: String
    var latitude: Double
    var longitude: Double
    var details: String
    var addedByUser: String
    var otherInfo: String
    var price: Float
    var status: String
    var id: String
    var createdAt: String
    var acceptedByUser: String
    var stripeChargeToken: String
    var firebaseReference: FIRDatabaseReference?

    init(address: String, addedByUser: String, status: String, latitude: Double, longitude: Double, details: String, otherInfo: String, price: Float, id: String, createdAt: String, acceptedByUser: String, stripeChargeToken: String) {
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
        self.firebaseReference = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! [String: Any]
        self.address = snapshotValue[ShovelRequest.AddressKey] as! String
        self.details = snapshotValue[ShovelRequest.DetailsKey] as! String
        self.latitude = snapshotValue[ShovelRequest.LatitudeKey] as! Double
        self.longitude = snapshotValue[ShovelRequest.LongitudeKey] as! Double
        self.otherInfo = snapshotValue[ShovelRequest.OtherInfoKey] as! String
        self.price = snapshotValue[ShovelRequest.PriceKey] as! Float
        self.addedByUser = snapshotValue[ShovelRequest.AddedByUserKey] as! String
        self.status = snapshotValue[ShovelRequest.StatusKey] as! String
        self.id = snapshotValue[ShovelRequest.IdKey] as! String
        self.createdAt = snapshotValue[ShovelRequest.CreatedAtKey] as! String
        self.acceptedByUser = snapshotValue[ShovelRequest.AcceptedByUserKey] as! String
        self.stripeChargeToken = snapshotValue[ShovelRequest.StripeChargeTokenKey] as! String
        self.firebaseReference = snapshot.ref
    }

    func toAnyObject() -> Any {
        return [
            ShovelRequest.AddressKey: self.address,
            ShovelRequest.DetailsKey: self.details,
            ShovelRequest.LatitudeKey: self.latitude,
            ShovelRequest.LongitudeKey: self.longitude,
            ShovelRequest.OtherInfoKey: self.otherInfo,
            ShovelRequest.PriceKey: self.price,
            ShovelRequest.StatusKey: self.status,
            ShovelRequest.IdKey: self.id,
            ShovelRequest.CreatedAtKey: self.createdAt,
            ShovelRequest.AcceptedByUserKey: self.acceptedByUser,
            ShovelRequest.StripeChargeTokenKey: self.stripeChargeToken,
            ShovelRequest.AddedByUserKey: self.addedByUser
        ]
    }
}
