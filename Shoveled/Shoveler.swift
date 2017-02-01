//
//  Shoveler.swift
//  Shoveled
//
//  Created by Joshua Walsh on 12/10/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation

class Shoveler: NSObject {
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
    }

    func toAnyObject() -> NSDictionary {
        return [
            "firstName": firstName,
            "lastName": lastName,
            "address1": address1,
            "city": city,
            "state": state,
            "postalCode": postalCode,
            "dobMonth": dobMonth,
            "dobDay": dobDay,
            "dobYear": dobYear,
            "stripeId": stripeId
        ]
    }
    convenience override init() {
        self.init(firstName: "",
                  lastName: "",
                  address1: "",
                  city: "",
                  state: "",
                  postalCode: "",
                  dobMonth: "",
                  dobDay: "",
                  dobYear: "",
                  stripeId: "")
    }
}
