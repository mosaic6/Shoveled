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

var currentUserUid: String {
    if let user = FIRAuth.auth()?.currentUser?.uid {
        return user
    }
    return ""
}

var currentUserEmail: String {
    if let email = FIRAuth.auth()?.currentUser?.email {
        return email
    }
    return ""
}
