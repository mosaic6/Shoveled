//
//  DebitCardCell.swift
//  Shoveled
//
//  Created by Joshua Walsh on 11/30/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit

class DebitCardCell: UITableViewCell {

    @IBOutlet weak var debitCardNumberLabel: UILabel?
    @IBOutlet weak var debitCardExpMonthLabel: UILabel?
    @IBOutlet weak var debitCardExpYearLabel: UILabel?    
    @IBOutlet weak var debitCardCVCLabel: UILabel?
    
    @IBOutlet weak var debitCardNumberTF: UITextField?
    @IBOutlet weak var debitCardExpMonthTF: UITextField?
    @IBOutlet weak var debitCardExpYearTF: UITextField?
    @IBOutlet weak var debitCardCVCTF: UITextField?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configureCells()
    }
    
    func configureCells() {
        self.debitCardNumberLabel?.text = "DEBIT CARD #"
        self.debitCardNumberTF?.placeholder = "XXXX XXXX XXXX XXXX"
        self.debitCardExpMonthLabel?.text = "EXP MONTH"
        self.debitCardExpMonthTF?.placeholder = "03"
        self.debitCardExpYearLabel?.text = "EXP YEAR"
        self.debitCardExpYearTF?.placeholder = "19"
        self.debitCardCVCLabel?.text = "CVC"
        self.debitCardCVCTF?.placeholder = "123"
    }
}
