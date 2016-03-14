//
//  API+Firebase.swift
//  Shoveled
//
//  Created by Joshua Walsh on 2/23/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation
import Firebase

let rootRef = Firebase(url: "https://shoveled.firebaseio.com")
let shovelRef = Firebase(url: "https://shoveled.firebaseio.com/shoveled-request")
let shovelItemRef = rootRef.childByAppendingPath("shovel-request")
let acceptRef = shovelRef.childByAppendingPath("accepted")
let usersRef = Firebase(url: "https://shoveled.firebaseio.com/online")

