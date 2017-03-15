//
//  Shoveler.swift
//  Shoveled
//
//  Created by Joshua Walsh on 12/10/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation
import Firebase

let FirstNameKey = "firstName"
let LastNameKey = "lastName"
let Address1Key = "address1"
let CityKey = "city"
let StateKey = "state"
let PostalCodeKey = "postalCode"
let DobMonthKey = "dobMonth"
let DobDayKey = "dobDay"
let DobYearKey = "dobYear"
let StripeIdKey = "stripeId"

struct Shoveler {
    var firstName: String
    var lastName: String
    var address1: String
    var city: String
    var state: String
    var postalCode: String
    var dobMonth: String
    var dobDay: String
    var dobYear: String
    var stripeId: String
    var firebaseReference: FIRDatabaseReference?

    init(firstName: String, lastName: String, address1: String, city: String, state: String, postalCode: String, dobMonth: String, dobDay: String, dobYear: String, stripeId: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.address1 = address1
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.dobMonth = dobMonth
        self.dobDay = dobDay
        self.dobYear = dobYear
        self.stripeId = stripeId
        self.firebaseReference = nil
    }

    init(snapshot: FIRDataSnapshot?) {
        let snapshotValue = snapshot?.value as? [String: Any]
        self.firstName = snapshotValue?[FirstNameKey] as! String
        self.lastName = snapshotValue?[LastNameKey] as! String
        self.address1 = snapshotValue?[Address1Key] as! String
        self.city = snapshotValue?[CityKey] as! String
        self.state = snapshotValue?[StateKey] as! String
        self.postalCode = snapshotValue?[PostalCodeKey] as! String
        self.dobMonth = snapshotValue?[DobMonthKey] as! String
        self.dobDay = snapshotValue?[DobDayKey] as! String
        self.dobYear = snapshotValue?[DobYearKey] as! String
        self.stripeId = snapshotValue?[StripeIdKey] as! String

    }

    func toAnyObject() -> NSDictionary {
        return [
            FirstNameKey: self.firstName,
            LastNameKey: self.lastName,
            Address1Key: self.address1,
            CityKey: self.city,
            StateKey: self.state,
            PostalCodeKey: self.postalCode,
            DobMonthKey: self.dobMonth,
            DobDayKey: self.dobDay,
            DobYearKey: self.dobYear,
            StripeIdKey: self.stripeId
        ]
    }
}
