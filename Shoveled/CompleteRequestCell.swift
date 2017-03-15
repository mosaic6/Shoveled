//
//  CompleteRequestCell.swift
//  Shoveled
//
//  Created by Joshua Walsh on 1/24/17.
//  Copyright © 2017 Lucky Penguin. All rights reserved.
//

import UIKit

class CompleteRequestCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel?
    @IBOutlet weak var completedJobImageView: UIImageView?
    @IBOutlet weak var takePhotoButton: UIButton?
    @IBOutlet weak var sendCompletedJobButton: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
