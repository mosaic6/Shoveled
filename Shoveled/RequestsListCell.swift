//
//  RequestsListCell.swift
//  Shoveled
//
//  Created by Joshua Walsh on 2/12/17.
//  Copyright © 2017 Lucky Penguin. All rights reserved.
//

import UIKit

class RequestsListCell: UITableViewCell {

    @IBOutlet weak var addressLabel: UILabel?
    @IBOutlet weak var dateCreatedLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
