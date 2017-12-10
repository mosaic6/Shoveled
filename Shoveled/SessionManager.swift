//
//  SessionManager.swift
//  Shoveled
//
//  Created by Joshua Walsh on 12/10/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation
import FirebaseDatabase

import Firebase
import FirebaseAuth

var shovelerRef = Database.database().reference()

var currentUserUid: String {
    guard let userId = Auth.auth().currentUser?.uid else { return "" }

    return userId
}

var currentUserEmail: String {
    if let email = Auth.auth().currentUser?.email {
        return email
    }
    return ""
}
