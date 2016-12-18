//
//  SettingsTableViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 11/28/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsTableViewController: UITableViewController {

    // MARK: Variables
    let settingsData = ["Shovelers Information", "FAQs", "Logout"]

    // MARK: Outlets
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "SETTINGS"
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.title = ""
    }

    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell

        cell.cellTitleLabel?.text = settingsData[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! SettingsCell
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if currentCell.cellTitleLabel?.text == "FAQs" {
            let viewController = storyboard.instantiateViewController(withIdentifier: "FAQViewController") as! FAQViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        } else if currentCell.cellTitleLabel?.text == "Shovelers Information" {
            let viewController = storyboard.instantiateViewController(withIdentifier: "PersonalInformationViewController") as! PersonalInformationViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        } else if currentCell.cellTitleLabel?.text == "Logout" {
            self.showMenu()
        }
    }
}

extension SettingsTableViewController {
    // MARK: - Actions
    func showMenu() {
        let logoutAction = UIAlertController(title: "ARE YOU SURE YOU WANT TO LOGOUT?", message: nil, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "LOGOUT", style: .destructive) { action in
            try! FIRAuth.auth()!.signOut()
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        logoutAction.addAction(okAction)
        logoutAction.addAction(cancelAction)
        self.present(logoutAction, animated: true, completion: nil)
    }
}
