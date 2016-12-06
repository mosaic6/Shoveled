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

class PersonalInformationViewController: UIViewController {
    
    fileprivate enum CellIdentifier {
        case firstNameCell
        case lastNameCell
        case addressCell
        case cityCell
        case stateCell
        case zipCell
        case dobCell
        case ssCell
        case cardNumberCell
        case cardExpMonthCell
        case cardExpYearCell
        case cardCVCCell
    }
    
    var profileDetailDictionary: [String: AnyObject] = [:]
    
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
    
    
    @IBOutlet weak var tableView: UITableView?
    
    @IBOutlet weak var tableViewBottomLayoutConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavbar()
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(PersonalInformationViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

    }
    
    func configureNavbar() {
        let saveBtn = UIButton()
        saveBtn.setTitle("Save", for: .normal)
        saveBtn.titleLabel?.textColor = UIColor(red: 23.0/255.0, green: 22.0/255.0, blue: 200.0/255.0, alpha: 1)
        saveBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        saveBtn.addTarget(self, action: #selector(PersonalInformationViewController.saveProfile), for: .touchUpInside)
        let rightBarBtn = UIBarButtonItem()
        rightBarBtn.customView = saveBtn
        self.navigationItem.rightBarButtonItem = rightBarBtn
    }
}

extension PersonalInformationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 || section == 1 {
            return "Your Name"
        } else if section == 2 || section == 3 || section == 4 || section == 5 {
            return "Address"
        } else if section == 6 || section == 7 {
            return "Identity Verification"
        } else {
            return "Debit Card"
        }

        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "firstNameCell", for: indexPath) as! PersonalInfoCell
            profileDetailDictionary["legal_entity[first_name]"] = cell.firstNameTF?.text as AnyObject?
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "lastNameCell", for: indexPath) as! PersonalInfoCell
            profileDetailDictionary["legal_entity[last_name]"] = cell.lastNameTF?.text as AnyObject?
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! PersonalInfoCell
            profileDetailDictionary["legal_entity[address][line1]"] = cell.addressTF?.text as AnyObject?
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as! PersonalInfoCell
            profileDetailDictionary["legal_entity[address][city]"] = cell.cityTF?.text as AnyObject?
            return cell
        } else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "stateCell", for: indexPath) as! PersonalInfoCell
            profileDetailDictionary["legal_entity[address][state]"] = cell.stateTF?.text as AnyObject?
            return cell
        } else if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "zipCell", for: indexPath) as! PersonalInfoCell
            profileDetailDictionary["legal_entity[address][postal_code]"] = cell.zipTF?.text as AnyObject?
            return cell
        } else if indexPath.row == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dobCell", for: indexPath) as! PersonalInfoCell
            profileDetailDictionary["legal_entity[dob][day]"] = cell.dobDayTF?.text as AnyObject?
            profileDetailDictionary["legal_entity[dob][month]"] = cell.dobMonthTF?.text as AnyObject?
            profileDetailDictionary["legal_entity[dob][year]"] = cell.dobYearTF?.text as AnyObject?
            return cell
        } else if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ssCell", for: indexPath) as! PersonalInfoCell
            profileDetailDictionary["legal_entity[ssn_last_4]"] = cell.ssTF?.text as AnyObject?
            return cell
        } else if indexPath.row == 8 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cardNumberCell", for: indexPath) as! DebitCardCell
            profileDetailDictionary["external_account[number]"] = cell.debitCardNumberTF?.text as AnyObject?
            return cell
        } else if indexPath.row == 9 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cardExpMonthCell", for: indexPath) as! DebitCardCell
            profileDetailDictionary["external_account[exp_month]"] = cell.debitCardExpMonthTF?.text as AnyObject?
            return cell
        } else if indexPath.row == 10 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cardExpYearCell", for: indexPath) as! DebitCardCell
            profileDetailDictionary["external_account[exp_year]"] = cell.debitCardExpYearTF?.text as AnyObject?
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cardCVCCell", for: indexPath) as! DebitCardCell
            profileDetailDictionary["external_account[cvc]"] = cell.debitCardCVCTF?.text as AnyObject?
            return cell
        }
        
    }
}

// MARK: Save personal information
extension PersonalInformationViewController {
    @objc
    fileprivate func saveProfile() {
        StripeManager.createManagedAccount(accountDict: profileDetailDictionary)        
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
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}
