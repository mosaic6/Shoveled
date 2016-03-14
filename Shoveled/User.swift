//
//  User.swift
//  Shoveled
//
//  Created by Joshua Walsh on 3/2/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation
import Firebase

struct User {
    let uid: String
    let email: String
    
    // Initialize from Firebase
    init(authData: FAuthData) {
        uid = authData.uid
        email = authData.providerData["email"] as! String
    }
    
    // Initialize from arbitrary data
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
}