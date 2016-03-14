//
//  MenuItemCell.swift
//  Taasky
//
//  Created by Audrey M Tam on 18/03/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

class MenuItemCell: UITableViewCell {
  
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        
    }
    
    func configureForItems(item: MenuItems) {
        lblTitle.text = item.title
    }
  
}
