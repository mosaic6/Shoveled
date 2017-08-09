//
//  PersonalInformationViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 11/29/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseDatabase

class ShovelersInformationViewController: UIViewController {

    fileprivate enum CellIdentifier: String {
        case firstNameCell = "firstNameCell"
        case lastNameCell = "lastNameCell"
        case addressCell = "addressCell"
        case cityCell = "cityCell"
        case stateCell = "stateCell"
        case zipCell = "zipCell"
        case dobCell = "dobCell"
        case ssCell = "ssCell"
        case bankAccountNumberCell = "bankAccountNumberCell"
        case bankRoutingNumberCell = "bankRoutingNumberCell"
    }

    fileprivate var tableViewData: [[CellIdentifier]] = []
    fileprivate var firstNameCell: PersonalInfoCell?
    fileprivate var lastNameCell: PersonalInfoCell?
    fileprivate var addressCell: PersonalInfoCell?
    fileprivate var cityCell: PersonalInfoCell?
    fileprivate var stateCell: PersonalInfoCell?
    fileprivate var zipCell: PersonalInfoCell?
    fileprivate var dobCell: PersonalInfoCell?
    fileprivate var ssCell: PersonalInfoCell?
    fileprivate var bankAccountNumberCell: BankAccountCell?
    fileprivate var bankRoutingNumberCell: BankAccountCell?

    fileprivate var firstName: String? {
        return self.firstNameCell?.firstNameTF?.text
    }

    fileprivate var lastName: String? {
        return self.lastNameCell?.lastNameTF?.text
    }

    fileprivate var address: String? {
        return self.addressCell?.addressTF?.text
    }

    fileprivate var city: String? {
        return self.cityCell?.cityTF?.text
    }

    fileprivate var state: String? {
        return self.stateCell?.stateTF?.text
    }

    fileprivate var zip: String? {
        return self.zipCell?.zipTF?.text
    }

    fileprivate var dobDay: String? {
        return self.dobCell?.dobDayTF?.text
    }

    fileprivate var dobMonth: String? {
        return self.dobCell?.dobMonthTF?.text
    }

    fileprivate var dobYear: String? {
        return self.dobCell?.dobYearTF?.text
    }

    fileprivate var ss: String? {
        return self.ssCell?.ssTF?.text
    }

    fileprivate var bankAccountNumber: String? {
        return self.bankAccountNumberCell?.accountNumberTF?.text
    }

    fileprivate var bankRoutingNumber: String? {
        return self.bankRoutingNumberCell?.routingNumberTF?.text
    }

    fileprivate var shoveler: Shoveler?
    fileprivate var saveBtn = UIButton()

    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    lazy var shovelerRef: FIRDatabaseReference = FIRDatabase.database().reference(withPath: "users")

    @IBOutlet weak var tableView: UITableView?

    @IBOutlet weak var tableViewBottomLayoutConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavbar()

        self.firstNameCell?.firstNameTF?.delegate = self
        self.lastNameCell?.lastNameTF?.delegate = self
        self.addressCell?.addressTF?.delegate = self
        self.cityCell?.cityTF?.delegate = self
        self.stateCell?.stateTF?.delegate = self
        self.zipCell?.zipTF?.delegate = self
        self.dobCell?.dobYearTF?.delegate = self
        self.dobCell?.dobMonthTF?.delegate = self
        self.dobCell?.dobDayTF?.delegate = self
        self.ssCell?.ssTF?.delegate = self
        self.bankAccountNumberCell?.accountNumberTF?.delegate = self
        self.bankRoutingNumberCell?.routingNumberTF?.delegate = self

        self.rebuildTableViewDataAndRefresh()

        NotificationCenter.default.addObserver(self, selector: #selector(ShovelersInformationViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

    }

    override func viewWillAppear(_ animated: Bool) {
        self.getShovelerInformation()
    }

    fileprivate func getShovelerInformation() {
        self.shovelerRef.observe(.value, with: { snapshot in
            if let items = snapshot.value as? [String: AnyObject] {
                for item in items {
                    if currentUserUid == item.key {
                        if let shoveler = item.value["shoveler"] as? NSDictionary {
                            guard let firstName = shoveler.object(forKey: "firstName") as? String else { return }
                            guard let lastName = shoveler.object(forKey: "lastName") as? String else { return }
                            guard let address1 = shoveler.object(forKey: "address1") as? String else { return }
                            guard let city = shoveler.object(forKey: "city") as? String else { return }
                            guard let state = shoveler.object(forKey: "state") as? String else { return }
                            guard let zip = shoveler.object(forKey: "postalCode") as? String else { return }
                            guard let dobDay = shoveler.object(forKey: "dobDay") as? String else { return }
                            guard let dobMonth = shoveler.object(forKey: "dobMonth") as? String else { return }
                            guard let dobYear = shoveler.object(forKey: "dobYear") as? String else { return }

                            self.firstNameCell?.firstNameTF?.text = firstName
                            self.lastNameCell?.lastNameTF?.text = lastName
                            self.addressCell?.addressTF?.text = address1
                            self.cityCell?.cityTF?.text = city
                            self.stateCell?.stateTF?.text = state
                            self.zipCell?.zipTF?.text = zip
                            self.dobCell?.dobDayTF?.text = dobDay
                            self.dobCell?.dobMonthTF?.text = dobMonth
                            self.dobCell?.dobYearTF?.text = dobYear
                        }
                    }
                }
            }
        })
    }

    func configureNavbar() {
        self.saveBtn = UIButton(type: .system)
        self.saveBtn.isEnabled = false
        self.saveBtn.setTitle("Save", for: .normal)
        self.saveBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        self.saveBtn.addTarget(self, action: #selector(ShovelersInformationViewController.saveProfile), for: .touchUpInside)
        let rightBarBtn = UIBarButtonItem()
        rightBarBtn.customView = self.saveBtn
        self.navigationItem.rightBarButtonItem = rightBarBtn
    }

    func rebuildTableViewDataAndRefresh() {
        let tableViewData: [[CellIdentifier]]

        tableViewData = self.tableViewDataForShovelerInformation()

        self.tableViewData = tableViewData
        self.tableView?.reloadData()
    }

    private func tableViewDataForShovelerInformation() -> [[CellIdentifier]] {
        var tableViewData: [[CellIdentifier]] = []

        var addressData: [CellIdentifier] = []

        addressData.append(.firstNameCell)
        addressData.append(.lastNameCell)
        addressData.append(.addressCell)
        addressData.append(.cityCell)
        addressData.append(.stateCell)
        addressData.append(.zipCell)
        addressData.append(.dobCell)
        addressData.append(.ssCell)
        addressData.append(.bankAccountNumberCell)
        addressData.append(.bankRoutingNumberCell)

        tableViewData.append(addressData)

        return tableViewData
    }
}

extension ShovelersInformationViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewData[section].count
    }

    fileprivate func indexPathForCellIdentifier(_ identifier: CellIdentifier) -> IndexPath? {
        for (sectionIndex, sectionData) in self.tableViewData.enumerated() {
            for (rowIndex, cellIdentifier) in sectionData.enumerated() {
                if cellIdentifier == identifier {
                    return IndexPath(row: rowIndex, section: sectionIndex)
                }
            }
        }

        return nil
    }

    fileprivate func identifier(at indexPath: IndexPath) -> CellIdentifier? {
        return self.tableViewData[indexPath.section][indexPath.row]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellIdentifier = self.identifier(at: indexPath) else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.rawValue)!

        switch cellIdentifier {
        case .firstNameCell:
            let firstNameCell = cell as! PersonalInfoCell
            self.firstNameCell = firstNameCell
        case .lastNameCell:
            let lastNameCell = cell as! PersonalInfoCell
            self.lastNameCell = lastNameCell
        case .addressCell:
            let address1Cell = cell as! PersonalInfoCell
            self.addressCell = address1Cell
        case .cityCell:
            let cityCell = cell as! PersonalInfoCell
            self.cityCell = cityCell
        case .stateCell:
            let stateCell = cell as! PersonalInfoCell
            stateCell.stateTF?.text = self.shoveler?.state
            self.stateCell = stateCell
        case .zipCell:
            let zipCell = cell as! PersonalInfoCell
            zipCell.zipTF?.text = self.shoveler?.postalCode
            self.zipCell = zipCell
        case .dobCell:
            let dobCell = cell as! PersonalInfoCell
            dobCell.dobMonthTF?.text = self.shoveler?.dobMonth
            dobCell.dobDayTF?.text = self.shoveler?.dobDay
            dobCell.dobYearTF?.text = self.shoveler?.dobYear
            self.dobCell = dobCell
        case .ssCell:
            let ssCell = cell as! PersonalInfoCell
            ssCell.ssInfoButton?.addTarget(self, action: #selector(ShovelersInformationViewController.moreInfoSSTapped), for: .touchUpInside)
            self.ssCell = ssCell
        case .bankAccountNumberCell:
            let bankAccountNumberCell = cell as! BankAccountCell
            self.bankAccountNumberCell = bankAccountNumberCell
        case .bankRoutingNumberCell:
            let bankRoutingNumberCell = cell as! BankAccountCell
            self.bankRoutingNumberCell = bankRoutingNumberCell
        }
        return cell
    }
}

// MARK: Save personal information
extension ShovelersInformationViewController {
    @objc
    fileprivate func saveProfile() {
        self.resignFirstResponder()
        if self.allTextFieldsHaveText() {
            self.showActivityIndicatory(self.view)
            if let firstName = self.firstName,
                let lastName = self.lastName,
                let address = self.address,
                let city = self.city,
                let state = self.state,
                let zip = self.zip,
                let dobDay = self.dobDay,
                let dobMonth = self.dobMonth,
                let dobYear = self.dobYear,
                let fullSS = self.ss,
                let bankAccountNumber = self.bankAccountNumber,
                let bankRoutingNumber = self.bankRoutingNumber {
                StripeManager.createManagedAccount(firstName: firstName, lastName: lastName, address1: address, city: city, state: state, zip: zip, dobDay: dobDay, dobMonth: dobMonth, dobYear: dobYear, fullSS: fullSS, accountRoutingNumber: bankRoutingNumber, accountAccountNumber: bankAccountNumber) { result, error in

                    if let result = result {
                        if let externalAccounts = result["external_accounts"] as? Dictionary<String, Any> {
                            for (key, value) in externalAccounts {
                                if key == "data" {
                                    if let data = value as? NSArray {
                                        for d in data {
                                            if let account = d as? NSDictionary {
                                                if let id = account.object(forKey: "account") as? String {
                                                    self.shoveler = Shoveler(firstName: firstName, lastName: lastName, address1: address, city: city, state: state, postalCode: zip, dobMonth: dobMonth, dobDay: dobDay, dobYear: dobYear, stripeId: id)
                                                    let requestName = self.ref.child("users").child(currentUserUid).child("shoveler")
                                                    requestName.setValue(self.shoveler?.toAnyObject()) { error, ref in
                                                        if error == nil {
                                                            self.hideActivityIndicator(self.view)
                                                            let alert = UIAlertController(title: "👍❄️💰", message: "Thank you for signing up as a shoveler! Go check for requests and get those people shoveled out!", preferredStyle: .alert)
                                                            let okAction = UIAlertAction(title: "Get Going!", style: .default) { action in
                                                                self.dismiss(animated: true, completion: nil)
                                                            }
                                                            alert.addAction(okAction)
                                                            self.present(alert, animated: true, completion: nil)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    fileprivate func allTextFieldsHaveText() -> Bool {
        var textFields: [UITextField] = []
        if let firstName = self.firstNameCell?.firstNameTF,
        let lastName = self.lastNameCell?.lastNameTF,
        let address = self.addressCell?.addressTF,
        let city = self.cityCell?.cityTF,
        let state = self.stateCell?.stateTF,
        let zip = self.zipCell?.zipTF,
        let dobDay = self.dobCell?.dobDayTF,
        let dobMonth = self.dobCell?.dobMonthTF,
        let dobYear = self.dobCell?.dobYearTF,
        let ss = self.ssCell?.ssTF,
        let bankAccountNumber = self.bankAccountNumberCell?.accountNumberTF,
        let bankRoutingNumber = self.bankRoutingNumberCell?.routingNumberTF {

            textFields.append(firstName)
            textFields.append(lastName)
            textFields.append(address)
            textFields.append(city)
            textFields.append(state)
            textFields.append(zip)
            textFields.append(dobDay)
            textFields.append(dobMonth)
            textFields.append(dobYear)
            textFields.append(ss)
            textFields.append(bankAccountNumber)
            textFields.append(bankRoutingNumber)

            for tf in textFields {
                if tf.text?.characters.count == 0 {
                    let alert = UIAlertController(title: "Uh oh!", message: "Looks like you forgot something", preferredStyle: .alert)
                    let okBtn = UIAlertAction(title: "Try again", style: .default, handler: nil)
                    alert.addAction(okBtn)
                    self.present(alert, animated: true, completion: nil)
                    tf.becomeFirstResponder()
                } else {
                    self.saveBtn.isEnabled = true
                    return true
                }
            }
        }
        return false
    }
}

extension ShovelersInformationViewController: UITextFieldDelegate {

    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.tableView?.frame.origin.y == 0 {
                self.tableViewBottomLayoutConstraint?.constant = keyboardSize.size.height
                self.tableViewBottomLayoutConstraint?.isActive = true
            }
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.firstNameCell?.firstNameTF {
            if let firstName = self.firstNameCell?.firstNameTF?.text?.characters.count {
                let newLength = firstName + string.characters.count - range.length
                return newLength <= 100
            }
        }

        if textField == self.lastNameCell?.lastNameTF {
            if let lastName = self.lastNameCell?.lastNameTF?.text?.characters.count {
                let newLength = lastName + string.characters.count - range.length
                return newLength <= 100
            }
        }

        if textField == self.addressCell?.addressTF {
            if let address = self.addressCell?.addressTF?.text?.characters.count {
                let newLength = address + string.characters.count - range.length
                return newLength <= 100
            }
        }

        if textField == self.cityCell?.cityTF {
            if let city = self.cityCell?.cityTF?.text?.characters.count {
                let newLength = city + string.characters.count - range.length
                return newLength <= 100
            }
        }

        if textField == self.stateCell?.stateTF {
            if let state = self.stateCell?.stateTF?.text?.characters.count {
                let newLength = state + string.characters.count - range.length
                return newLength <= 2
            }
        }

        if textField == self.zipCell?.zipTF {
            if let zip = self.zipCell?.zipTF?.text?.characters.count {
                let newLength = zip + string.characters.count - range.length
                return newLength <= 5
            }
        }

        if textField == self.dobCell?.dobMonthTF {
            if let dobMonth = self.dobCell?.dobMonthTF?.text?.characters.count {
                let newLength = dobMonth + string.characters.count - range.length
                if newLength == 3 {
                    self.dobCell?.dobDayTF?.becomeFirstResponder()
                }
                return newLength <= 2

            }
        }

        if textField == self.dobCell?.dobDayTF {
            if let dobDay = self.dobCell?.dobDayTF?.text?.characters.count {
                let newLength = dobDay + string.characters.count - range.length
                if newLength == 3 {
                    self.dobCell?.dobYearTF?.becomeFirstResponder()
                }
                return newLength <= 2

            }
        }

        if textField == self.dobCell?.dobYearTF {
            if let dobYear = self.dobCell?.dobYearTF?.text?.characters.count {
                let newLength = dobYear + string.characters.count - range.length
                return newLength <= 4
            }
        }

        if textField == self.ssCell?.ssTF {
            if let ss = self.ssCell?.ssTF?.text?.characters.count {
                let newLength = ss + string.characters.count - range.length
                return newLength <= 9
            }
        }

        if textField == self.bankAccountNumberCell?.accountNumberTF {
            if let accountNumber = self.bankAccountNumberCell?.accountNumberTF?.text?.characters.count {
                let newLength = accountNumber + string.characters.count - range.length
                return newLength <= 15
            }
        }

        if textField == self.bankRoutingNumberCell?.routingNumberTF {
            if let routingNumber = self.bankRoutingNumberCell?.routingNumberTF?.text?.characters.count {
                let newLength = routingNumber + string.characters.count - range.length
                return newLength <= 15
            }
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.firstNameCell?.firstNameTF {
            if let firstName = self.firstNameCell?.firstNameTF {
                firstName.text = self.firstName
            }
        }
        if textField == self.lastNameCell?.lastNameTF {
            if let lastName = self.lastNameCell?.lastNameTF {
                lastName.text = self.lastName
            }
        }
        if textField == self.addressCell?.addressTF {
            if let address = self.addressCell?.addressTF {
                address.text = self.address
            }
        }
        if textField == self.cityCell?.cityTF {
            if let city = self.cityCell?.cityTF {
                city.text = self.city
            }
        }
        if textField == self.stateCell?.stateTF {
            if let state = self.stateCell?.stateTF {
                state.text = self.state
            }
        }
        if textField == self.zipCell?.zipTF {
            if let zip = self.zipCell?.zipTF {
                zip.text = self.zip
            }
        }
        if textField == self.dobCell?.dobDayTF {
            if let dobDay = self.dobCell?.dobDayTF {
                dobDay.text = self.dobDay
            }
        }
        if textField == self.dobCell?.dobMonthTF {
            if let dobMonth = self.dobCell?.dobMonthTF {
                dobMonth.text = self.dobMonth
            }
        }
        if textField == self.dobCell?.dobYearTF {
            if let dobYear = self.dobCell?.dobYearTF {
                dobYear.text = self.dobYear
            }
        }
        if textField == self.ssCell?.ssTF {
            if let ss = self.ssCell?.ssTF {
                ss.text = self.ss
            }
        }
        if textField == self.bankAccountNumberCell?.accountNumberTF {
            if let accountNumber = self.bankAccountNumberCell?.accountNumberTF {
                accountNumber.text = self.bankAccountNumber
            }
        }
        if textField == self.bankRoutingNumberCell?.routingNumberTF {
            if let routingNumber = self.bankRoutingNumberCell?.routingNumberTF {
                routingNumber.text = self.bankRoutingNumber
            }
        }
    }
}

extension ShovelersInformationViewController {
    @objc func moreInfoSSTapped() {
        let alert = UIAlertController(title: "Why do we need this?", message: "In order to verify you're identity for transfering you payments, we need your SS# as a one time identifier. We do not store this or share with anyone. If you want to update your bank account you'll need to enter this again for verification.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { action in

        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
