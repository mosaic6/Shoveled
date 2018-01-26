//
//  PersonalInfoCell.swift
//  Shoveled
//
//  Created by Joshua Walsh on 11/29/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit

class PersonalInfoCell: UITableViewCell {

    let datePicker: UIDatePicker = UIDatePicker()
    let dateFormatter = DateFormatter()

    var dobDay: String? {
        return self.parseDayFromDatePicker()
    }

    var dobMonth: String? {
        return self.parseMonthFromDatePicker()
    }

    var dobYear: String? {
        return self.parseYearFromDatePicker()
    }

    @IBOutlet weak var firstNameTF: UITextField?
    @IBOutlet weak var lastNameTF: UITextField?
    @IBOutlet weak var addressTF: UITextField?
    @IBOutlet weak var cityTF: UITextField?
    @IBOutlet weak var dobTextField: UITextField?
    @IBOutlet weak var stateTF: UITextField?
    @IBOutlet weak var zipTF: UITextField?
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

    @IBAction func dobTextFieldDidBeginEditing(_ sender: UITextField) {
        datePicker.datePickerMode = .date
        sender.inputView = datePicker
        datePicker.addTarget(self, action: #selector(PersonalInfoCell.datePickerValueChanged), for: .valueChanged)
    }

    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        self.dobTextField?.text = dateFormatter.string(from: sender.date)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.configureCells()
    }

    fileprivate func configureCells() {
        self.firstNameLabel?.text = "FIRST NAME"
        self.lastNameLabel?.text = "LAST NAME"
        self.addressLabel?.text = "ADDRESS"
        self.cityLabel?.text = "CITY"
        self.stateLabel?.text = "STATE"
        self.zipLabel?.text = "ZIP"
        self.dobLabel?.text = "DATE OF BIRTH"
        self.ssLabel?.text = "FULL SS #"
        self.ssTF?.placeholder = "XXX XX XXXX"
    }

    func parseDayFromDatePicker() -> String {
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self.datePicker.date)
    }

    func parseMonthFromDatePicker() -> String {
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: self.datePicker.date)
    }

    func parseYearFromDatePicker() -> String {
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self.datePicker.date)
    }
}
