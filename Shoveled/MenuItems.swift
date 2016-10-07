//
//  MenuItems.swift
//  Shoveled
//
//  Created by Joshua Walsh on 3/5/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation

class MenuItems {
    
    let title: String
    
    init(title: String) {
        self.title = title
    }
    
    class func allItems() -> Array<MenuItems> {
        return [
            MenuItems(title: "Logout")
        ]
    }

}
