//
//  RequestDetailCell.swift
//  Shoveled
//
//  Created by Joshua Walsh on 1/17/17.
//  Copyright © 2017 Lucky Penguin. All rights reserved.
//

import UIKit

class RequestDetailCell: UITableViewCell {

    @IBOutlet weak var addressLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var moreInfoLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    @IBOutlet weak var acceptButton: UIButton?
    @IBOutlet weak var completeButton: UIButton?
    @IBOutlet weak var cancelButton: UIButton?
    @IBOutlet weak var shovelerSignUpButton: UIButton?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
