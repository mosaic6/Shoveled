//
//  SessionManager.swift
//  Shoveled
//
//  Created by Joshua Walsh on 12/10/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation

import Firebase
import FirebaseAuth

var shovelerRef: FIRDatabaseReference? = FIRDatabase.database().reference()

var currentUserUid: String {
    guard let userId = FIRAuth.auth()?.currentUser?.uid else { return "" }

    return userId
}

var currentUserEmail: String {
    if let email = FIRAuth.auth()?.currentUser?.email {
        return email
    }
    return ""
}
