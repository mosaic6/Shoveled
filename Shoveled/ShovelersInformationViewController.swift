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
import MessageUI

class ShovelersInformationViewController: UIViewController {

    // MARK: Varibles

    private var tableViewData: [[CellIdentifier]] = []
    private var firstNameCell: PersonalInfoCell?
    private var lastNameCell: PersonalInfoCell?
    private var addressCell: PersonalInfoCell?
    private var cityCell: PersonalInfoCell?
    private var stateCell: PersonalInfoCell?
    private var zipCell: PersonalInfoCell?
    private var dobCell: PersonalInfoCell?
    private var ssCell: PersonalInfoCell?
    private var bankAccountNumberCell: BankAccountCell?
    private var bankRoutingNumberCell: BankAccountCell?
    private var existingShovelerCell: ShovelersInfoCell?

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
        return self.dobCell?.dobDay
    }

    fileprivate var dobMonth: String? {
        return self.dobCell?.dobMonth
    }

    fileprivate var dobYear: String? {
        return self.dobCell?.dobYear
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
    fileprivate var isExistingCustomer = false

    lazy var ref = Database.database().reference()
    lazy var shovelerRef = Database.database().reference(withPath: "users")

    // MARK: Outlets

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var tableViewBottomLayoutConstraint: NSLayoutConstraint?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavbar()

        self.firstNameCell?.firstNameTF?.delegate = self
        self.lastNameCell?.lastNameTF?.delegate = self
        self.addressCell?.addressTF?.delegate = self
        self.cityCell?.cityTF?.delegate = self
        self.stateCell?.stateTF?.delegate = self
        self.zipCell?.zipTF?.delegate = self
        self.dobCell?.dobTextField?.delegate = self
        self.ssCell?.ssTF?.delegate = self
        self.bankAccountNumberCell?.accountNumberTF?.delegate = self
        self.bankRoutingNumberCell?.routingNumberTF?.delegate = self

        self.rebuildTableViewDataAndRefresh()

        NotificationCenter.default.addObserver(self, selector: #selector(ShovelersInformationViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getShovelerInformation()
        self.configureViewForShoveler()
        self.rebuildTableViewDataAndRefresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.getShovelerInformation()
    }

    fileprivate func getShovelerInformation() {
        self.shovelerRef.observe(.value, with: { snapshot in
            if let items = snapshot.value as? [String: AnyObject] {
                if !items.isEmpty {
                    self.saveBtn.isEnabled = false
                }
                for item in items {
                    if currentUserUid == item.key {
                        if let shoveler = item.value["shoveler"] as? NSDictionary {
                            guard let firstName = shoveler.object(forKey: "firstName") as? String,
                            let lastName = shoveler.object(forKey: "lastName") as? String,
                            let address1 = shoveler.object(forKey: "address1") as? String,
                            let city = shoveler.object(forKey: "city") as? String,
                            let state = shoveler.object(forKey: "state") as? String,
                            let zip = shoveler.object(forKey: "postalCode") as? String,
                            let dobDay = shoveler.object(forKey: "dobDay") as? String,
                            let dobMonth = shoveler.object(forKey: "dobMonth") as? String,
                            let dobYear = shoveler.object(forKey: "dobYear") as? String else {
                                return
                            }

                            self.firstNameCell?.firstNameTF?.text = firstName
                            self.lastNameCell?.lastNameTF?.text = lastName
                            self.addressCell?.addressTF?.text = address1
                            self.cityCell?.cityTF?.text = city
                            self.stateCell?.stateTF?.text = state
                            self.zipCell?.zipTF?.text = zip
                            self.dobCell?.dobTextField?.text = "\(dobMonth) \(dobDay), \(dobYear)"
                            self.isExistingCustomer = true
                            return
                        }
                    }
                }
            }
        })
    }

    fileprivate func updateShovelerInformation() {
        // if value changed on text fields enable save button
        // update firebase Shoveler object
        // update stripe customer object
    }

    // MARK: Configure View

    func configureNavbar() {
        if self.isExistingCustomer {
            self.saveBtn.isHidden = true
        }
        self.saveBtn = UIButton(type: .system)
        self.saveBtn.isEnabled = false
        self.saveBtn.setTitle("Save", for: .normal)
        self.saveBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        self.saveBtn.addTarget(self, action: #selector(ShovelersInformationViewController.saveProfile), for: .touchUpInside)
        let rightBarBtn = UIBarButtonItem()
        rightBarBtn.customView = self.saveBtn
        self.navigationItem.rightBarButtonItem = rightBarBtn
    }

    func configureViewForShoveler() {
        if self.isExistingCustomer {
            self.saveBtn.isHidden = true
        }
    }

    // MARK: TableViewData

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
        if !self.isExistingCustomer {
            addressData.append(.ssCell)
            addressData.append(.bankAccountNumberCell)
            addressData.append(.bankRoutingNumberCell)
        }

        if self.isExistingCustomer {
            addressData.append(.existingShovelerCell)
        }

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

    private func indexPathForCellIdentifier(_ identifier: CellIdentifier) -> IndexPath? {
        for (sectionIndex, sectionData) in self.tableViewData.enumerated() {
            for (rowIndex, cellIdentifier) in sectionData.enumerated() {
                if cellIdentifier == identifier {
                    return IndexPath(row: rowIndex, section: sectionIndex)
                }
            }
        }

        return nil
    }

    private func identifier(at indexPath: IndexPath) -> CellIdentifier? {
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
        case .existingShovelerCell:
            let shovelersInfoCell = cell as! ShovelersInfoCell
            shovelersInfoCell.contactShoveledButton?.addTarget(self, action: #selector(ShovelersInformationViewController.openEmail), for: .touchUpInside)
            self.existingShovelerCell = shovelersInfoCell
        }
        return cell
    }
}

// MARK: Save personal information
extension ShovelersInformationViewController {
    @objc fileprivate func saveProfile() {
        self.resignFirstResponder()
        if self.allTextFieldsHaveText() {
            self.showActivityIndicatory(self.view)
            guard let firstName = self.firstName,
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
                let bankRoutingNumber = self.bankRoutingNumber else {
                    return
            }

            StripeManager.sharedInstance.createManagedAccount(firstName: firstName, lastName: lastName, address1: address, city: city, state: state, zip: zip, dobDay: dobDay, dobMonth: dobMonth, dobYear: dobYear, fullSS: fullSS, accountRoutingNumber: bankRoutingNumber, accountAccountNumber: bankAccountNumber) { result, error in

                if let resultError = result?["error"] as? Dictionary<String, String> {
                    for (_, _) in resultError {
                        let alertMessage = resultError["message"] ?? ""
                        let alert = UIAlertController(title: "🤔", message: alertMessage, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default)
                        alert.addAction(okAction)
                        DispatchQueue.main.async {
                            self.hideActivityIndicator(self.view)
                            self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                }

                if let result = result {
                    if let externalAccounts = result["external_accounts"] as? Dictionary<String, Any> {
                        for (key, value) in externalAccounts {
                            if key == "data" {
                                if let data = value as? NSArray {
                                    for d in data {
                                        if let account = d as? NSDictionary {
                                            if let id = account.object(forKey: "account") as? String {
                                                self.shoveler = Shoveler(firstName: firstName, lastName: lastName, address1: address, city: city, state: state, postalCode: zip, dobMonth: "", dobDay: "", dobYear: "", stripeId: id)
                                                let requestName = self.ref.child("users").child(currentUserUid).child("shoveler")
                                                requestName.setValue(self.shoveler?.toAnyObject()) { error, _ in
                                                    if error == nil {
                                                        let alert = UIAlertController(title: "👍❄️💰", message: "Thank you for signing up as a shoveler! Go check for requests and get those people shoveled out!", preferredStyle: .alert)
                                                        let okAction = UIAlertAction(title: "Get Going!", style: .default) { _ in
                                                            self.dismiss(animated: true, completion: nil)
                                                        }
                                                        alert.addAction(okAction)
                                                        DispatchQueue.main.async {
                                                            self.hideActivityIndicator(self.view)
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
        let dob = self.dobCell?.dobTextField,
        let ss = self.ssCell?.ssTF,
        let bankAccountNumber = self.bankAccountNumberCell?.accountNumberTF,
        let bankRoutingNumber = self.bankRoutingNumberCell?.routingNumberTF {

            textFields.append(firstName)
            textFields.append(lastName)
            textFields.append(address)
            textFields.append(city)
            textFields.append(state)
            textFields.append(zip)
            textFields.append(dob)
            textFields.append(ss)
            textFields.append(bankAccountNumber)
            textFields.append(bankRoutingNumber)

            for tf in textFields {
                if tf.text?.count == 0 {
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

// MARK: Textfield delegate

extension ShovelersInformationViewController {

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.tableView?.frame.origin.y == 0 {
                self.tableViewBottomLayoutConstraint?.isActive = true
                self.tableViewBottomLayoutConstraint?.constant = keyboardSize.size.height
            }
        }
    }

    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""

        guard let stringRange = Range(range, in: currentText) else {
            return false

        }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        if textField == self.firstNameCell?.firstNameTF || textField == self.lastNameCell?.lastNameTF || textField == self.addressCell?.addressTF || textField == self.cityCell?.cityTF {
            return updatedText.count <= 100 // Change limit based on your requirement.
        }

        if textField == self.stateCell?.stateTF {
            return updatedText.count <= 2
        }

        if textField == self.zipCell?.zipTF {
            return updatedText.count <= 5
        }

        if textField == self.ssCell?.ssTF {
            return updatedText.count <= 9
        }

        if textField == self.bankAccountNumberCell?.accountNumberTF || textField == self.bankRoutingNumberCell?.routingNumberTF {
            return updatedText.count <= 15
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

        self.saveBtn.isEnabled = true
    }
}

// MARK: CellIdentifier

extension ShovelersInformationViewController {

    private enum CellIdentifier: String {
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
        case existingShovelerCell = "existingShovelerInfoCell"
    }
}

extension ShovelersInformationViewController {
    @objc func moreInfoSSTapped() {
        let alert = UIAlertController(title: "Why do we need this?", message: "In order to verify you're identity for transfering you payments, we need your SS# as a one time identifier. We do not store this or share with anyone. If you want to update your bank account you'll need to enter this again for verification.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in

        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: Message Composer delegate

extension ShovelersInformationViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }

    @objc func openEmail() {
        if MFMailComposeViewController.canSendMail() {
            let emailVC = MFMailComposeViewController()
            emailVC.mailComposeDelegate = self
            emailVC.setToRecipients(["support@shoveled.works"])
            emailVC.setSubject("Shovelers Info Update")
            self.present(emailVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "", message: "We don't currently support your email client. Please open your email and send your questions to support@shoveled.works", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
