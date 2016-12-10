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

class PersonalInformationViewController: UIViewController {
    
    fileprivate enum CellIdentifier: String {
        case firstNameCell = "firstNameCell"
        case lastNameCell = "lastNameCell"
        case addressCell = "addressCell"
        case cityCell = "cityCell"
        case stateCell = "stateCell"
        case zipCell = "zipCell"
        case dobCell = "dobCell"
        case ssCell = "ssCell"
        case cardNumberCell = "cardNumberCell"
        case cardExpMonthCell = "cardExpMonthCell"
        case cardExpYearCell = "cardExpYearCell"
        case cardCVCCell = "cardCVCCell"
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
    fileprivate var cardNumberCell: DebitCardCell?
    fileprivate var cardExpMonthCell: DebitCardCell?
    fileprivate var cardExpYearCell: DebitCardCell?
    fileprivate var cardCVCCell: DebitCardCell?
    
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
    
    fileprivate var cardNumber: String? {
        return self.cardNumberCell?.debitCardNumberTF?.text
    }
    
    fileprivate var cardExpMonth: String? {
        return self.cardExpMonthCell?.debitCardExpMonthTF?.text
    }
    
    fileprivate var cardExpYear: String? {
        return self.cardExpYearCell?.debitCardExpYearTF?.text
    }
    
    fileprivate var cardCVC: String? {
        return self.cardCVCCell?.debitCardCVCTF?.text
    }
    
    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()

    
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
        self.cardNumberCell?.debitCardNumberTF?.delegate = self
        self.cardExpMonthCell?.debitCardExpMonthTF?.delegate = self
        self.cardExpYearCell?.debitCardExpYearTF?.delegate = self
        self.cardCVCCell?.debitCardCVCTF?.delegate = self        
        
        self.rebuildTableViewDataAndRefresh()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PersonalInformationViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func configureNavbar() {
        let saveBtn = UIButton()
        saveBtn.isEnabled = false
        saveBtn.titleLabel?.textColor = UIColor.blue
        saveBtn.setTitle("Save", for: .normal)
        saveBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        saveBtn.addTarget(self, action: #selector(PersonalInformationViewController.saveProfile), for: .touchUpInside)
        let rightBarBtn = UIBarButtonItem()
        rightBarBtn.customView = saveBtn
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
        addressData.append(.cardNumberCell)
        addressData.append(.cardExpMonthCell)
        addressData.append(.cardExpYearCell)
        addressData.append(.cardCVCCell)
        
        tableViewData.append(addressData)
        
        return tableViewData
    }

}

extension PersonalInformationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewData[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
        if let firstCellIdentifier = self.tableViewData[section].first {
            switch firstCellIdentifier {
            case .firstNameCell, .lastNameCell, .addressCell, .cityCell, .stateCell, .zipCell:
                return "Personal Information"
            case .dobCell, .ssCell:
                return "Identity Verification"
            case .cardNumberCell, .cardExpMonthCell, .cardExpYearCell, .cardCVCCell:
                return "Payment Information"
            }
        }
        
        return nil
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
            self.stateCell = stateCell
        case .zipCell:
            let zipCell = cell as! PersonalInfoCell
            self.zipCell = zipCell
        case .dobCell:
            let dobCell = cell as! PersonalInfoCell
            self.dobCell = dobCell
        case .ssCell:
            let ssCell = cell as! PersonalInfoCell
            self.ssCell = ssCell
        case .cardNumberCell:
            let cardNumberCell = cell as! DebitCardCell
            self.cardNumberCell = cardNumberCell
        case .cardExpMonthCell:
            let cardExpMonthCell = cell as! DebitCardCell
            self.cardExpMonthCell = cardExpMonthCell
        case .cardExpYearCell:
            let cardExpYearCell = cell as! DebitCardCell
            self.cardExpYearCell = cardExpYearCell
        case .cardCVCCell:
            let cardCVCCell = cell as! DebitCardCell
            self.cardCVCCell = cardCVCCell
        }
        return cell
    }
}

// MARK: Save personal information
extension PersonalInformationViewController {
    @objc
    fileprivate func saveProfile() {
        if self.allTextFieldsHaveText() {
            if let firstName = self.firstName,
                let lastName = self.lastName,
                let address = self.address,
                let city = self.city,
                let state = self.state,
                let zip = self.zip,
                let dobDay = self.dobDay,
                let dobMonth = self.dobMonth,
                let dobYear = self.dobYear,
                let last4 = self.ss,
                let cardNumber = self.cardNumber,
                let expMonth = self.cardExpMonth,
                let expYear = self.cardExpYear,
                let cvc = self.cardCVC {
                StripeManager.createManagedAccount(firstName: firstName, lastName: lastName, address1: address, city: city, state: state, zip: zip, dobDay: dobDay, dobMonth: dobMonth, dobYear: dobYear, last4: last4, cardNumber: cardNumber, expMonth: expMonth, expYear: expYear, cvc: cvc) { result, error in
                    
                    var accountId: String?
                    if let result = result {
                        if let externalAccounts = result.object(forKey: "external_accounts") as? NSDictionary {
                            for (key, value) in externalAccounts {
                                if key as! String == "data" {
                                    if let data = value as? NSArray {
                                        for d in data {
                                            if let account = d as? NSDictionary {
                                                if let id = account.object(forKey: "account") as? String {
                                                    accountId = id
                                                    self.ref.child("users").child(currentUserUid).setValue(["stripeAcountId": accountId])                                                    
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
        let cardNumber = self.cardNumberCell?.debitCardNumberTF,
        let expMonth = self.cardExpMonthCell?.debitCardExpMonthTF,
        let expYear = self.cardExpYearCell?.debitCardExpYearTF,
        let cvc = self.cardCVCCell?.debitCardCVCTF {
            
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
            textFields.append(cardNumber)
            textFields.append(expMonth)
            textFields.append(expYear)
            textFields.append(cvc)
        
            for tf in textFields {
                if tf.text?.characters.count == 0 {
                    let alert = UIAlertController(title: "Uh oh!", message: "Looks like you forgot something", preferredStyle: .alert)
                    let okBtn = UIAlertAction(title: "Try again", style: .default, handler: nil)
                    alert.addAction(okBtn)
                    self.present(alert, animated: true, completion: nil)
                    tf.becomeFirstResponder()
                } else {
                    return true
                }
            }
        }
        return false
    }
}

extension PersonalInformationViewController: UITextFieldDelegate {
   
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
                return newLength <= 4
            }
        }

        if textField == self.cardNumberCell?.debitCardNumberTF {
            if let cardNumber = self.cardNumberCell?.debitCardNumberTF?.text?.characters.count {
                let newLength = cardNumber + string.characters.count - range.length
                return newLength <= 16
            }
        }
        
        if textField == self.cardExpMonthCell?.debitCardExpMonthTF {
            if let cardExpMonth = self.cardExpMonthCell?.debitCardExpMonthTF?.text?.characters.count {
                let newLength = cardExpMonth + string.characters.count - range.length
                return newLength <= 2
            }
        }

        if textField == self.cardExpYearCell?.debitCardExpYearTF {
            if let cardExpYear = self.cardExpYearCell?.debitCardExpYearTF?.text?.characters.count {
                let newLength = cardExpYear + string.characters.count - range.length
                return newLength <= 2
            }
        }

        if textField == self.cardCVCCell?.debitCardCVCTF {
            if let cardCVC = self.cardCVCCell?.debitCardCVCTF?.text?.characters.count {
                let newLength = cardCVC + string.characters.count - range.length
                return newLength <= 4
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
        if textField == self.cardNumberCell?.debitCardNumberTF {
            if let cardNum = self.cardNumberCell?.debitCardNumberTF {
                cardNum.text = self.cardNumber?.stringForCreditCardProcessing
            }
        }
        if textField == self.cardExpMonthCell?.debitCardExpMonthTF {
            if let expMonth = self.cardExpMonthCell?.debitCardExpMonthTF {
                expMonth.text = self.cardExpMonth
            }
        }
        if textField == self.cardExpYearCell?.debitCardExpYearTF {
            if let expYear = self.cardExpYearCell?.debitCardExpYearTF {
                expYear.text = self.cardExpYear
            }
        }
        if textField == self.cardCVCCell?.debitCardCVCTF {
            if let cvc = self.cardCVCCell?.debitCardCVCTF {
                cvc.text = self.cardCVC
            }
        }                
    }
}
