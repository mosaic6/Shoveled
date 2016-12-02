//
//  PersonalInfoCell.swift
//  Shoveled
//
//  Created by Joshua Walsh on 11/29/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit

class PersonalInfoCell: UITableViewCell {
     
    @IBOutlet weak var firstNameTF: UITextField?
    @IBOutlet weak var lastNameTF: UITextField?
    @IBOutlet weak var addressTF: UITextField?
    @IBOutlet weak var cityTF: UITextField?
    @IBOutlet weak var stateTF: UITextField?
    @IBOutlet weak var zipTF: UITextField?
    @IBOutlet weak var dobTF: UITextField?
    @IBOutlet weak var ssTF: UITextField?
    @IBOutlet weak var ssInfoButton: UIButton?
    
    @IBOutlet weak var firstNameLabel: UILabel?
    @IBOutlet weak var lastNameLabel: UILabel?
    @IBOutlet weak var addressLabel: UILabel?
    @IBOutlet weak var cityLabel: UILabel?
    @IBOutlet weak var stateLabel: UILabel?
    @IBOutlet weak var zipLabel: UILabel?
    @IBOutlet weak var dobLabel: UILabel?
    @IBOutlet weak var ssLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.firstNameTF?.delegate = self
//        self.lastNameTF?.delegate = self
//        self.addressTF?.delegate = self
//        self.cityTF?.delegate = self
//        self.stateTF?.delegate = self
//        self.zipTF?.delegate = self
//        self.dobTF?.delegate = self
//        self.ssTF?.delegate = self
        self.configureCells()
    }

    func configureCells() {
        self.firstNameLabel?.text = "FIRST NAME"
        self.lastNameLabel?.text = "LAST NAME"
        self.addressLabel?.text = "ADDRESS"
        self.cityLabel?.text = "CITY"
        self.stateLabel?.text = "STATE"
        self.zipLabel?.text = "ZIP"
        self.dobLabel?.text = "DATE OF BIRTH"
        self.ssLabel?.text = "SS LAST 4"
        
        self.dobTF?.placeholder = "03/21/1975"
    }
}
