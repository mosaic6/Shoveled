//
//  RequestCell.swift
//  Shoveled
//
//  Created by Joshua Walsh on 12/12/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit
import Stripe

class RequestCell: UITableViewCell, STPPaymentCardTextFieldDelegate {

    var tfCardDetails: STPPaymentCardTextField? = nil

    @IBOutlet weak var tfAddress: UITextField?
    @IBOutlet weak var tfDescription: UITextField?
    @IBOutlet weak var tfMoreInfo: UITextField?
    @IBOutlet weak var tfPrice: UITextField?
    @IBOutlet weak var tfCardInfo: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.configureCells()
    }

    func configureCells() {
        guard let width = self.tfCardInfo?.frame.size.width else { return }
        guard let height = self.tfCardInfo?.frame.size.height else { return }
        self.tfCardDetails = STPPaymentCardTextField(frame: CGRect(x: 0, y: 0, width: width - 30, height: height))
        self.tfCardDetails?.font = UIFont(name: "System", size: 14.0)
        self.tfCardDetails?.layer.borderWidth = 0.0
        self.tfCardDetails?.delegate = self
        if let tfCardDetails = self.tfCardDetails {
            self.tfCardInfo?.addSubview(tfCardDetails)
        }
    }
}
