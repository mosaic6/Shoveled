//
//  PersonalInformationViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 11/29/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit
import Foundation

class PersonalInformationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension PersonalInformationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
//    
//    private func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "firstNameCell", for: indexPath) as! PersonalInfoCell
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "lastNameCell", for: indexPath) as! PersonalInfoCell
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! PersonalInfoCell
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as! PersonalInfoCell
            return cell
        } else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "stateCell", for: indexPath) as! PersonalInfoCell
            return cell
        } else if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "zipCell", for: indexPath) as! PersonalInfoCell
            return cell
        } else if indexPath.row == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dobCell", for: indexPath) as! PersonalInfoCell
            return cell
        } else if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ssCell", for: indexPath) as! PersonalInfoCell
            return cell
        } else if indexPath.row == 8 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cardNumberCell", for: indexPath) as! DebitCardCell
            return cell
        } else if indexPath.row == 9 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cardExpMonthCell", for: indexPath) as! DebitCardCell
            return cell
        } else if indexPath.row == 10 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cardExpYearCell", for: indexPath) as! DebitCardCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cardCVCCell", for: indexPath) as! DebitCardCell
            return cell
        }
        
    }
}
