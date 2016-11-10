//
//  User.swift
//  Shoveled
//
//  Created by Joshua Walsh on 6/23/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation
import UIKit

class User: NSObject {
    var username: String

    init(username: String) {
        self.username = username
    }

    convenience override init() {
        self.init(username:  "")
    }
}
