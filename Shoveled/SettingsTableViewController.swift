//
//  SettingsTableViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 11/28/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import MessageUI

class SettingsTableViewController: UITableViewController {

    // MARK: Variables
    var settingsData = ["Become a Shoveler", "Help", "Logout"]
    lazy var shovelerRef = Database.database().reference(withPath: "users")

    // MARK: Outlets
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "SETTINGS"
        self.getShovelersInformation()
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
        if currentCell.cellTitleLabel?.text == "Help" {
            self.openEmail()
        } else if currentCell.cellTitleLabel?.text == "Shovelers Information" || currentCell.cellTitleLabel?.text == "Become a Shoveler" {
            let viewController = storyboard.instantiateViewController(withIdentifier: "PersonalInformationViewController") as! ShovelersInformationViewController
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
        let okAction = UIAlertAction(title: "LOGOUT", style: .destructive) { _ in
            try! Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        logoutAction.addAction(okAction)
        logoutAction.addAction(cancelAction)
        self.present(logoutAction, animated: true, completion: nil)
    }
}

extension SettingsTableViewController {
    func getShovelersInformation() {
        self.shovelerRef.observe(.value, with: { snapshot in
            if let items = snapshot.value as? [String: AnyObject] {
                for item in items {
                    if currentUserUid == item.key {
                        if let shoveler = item.value["shoveler"] as? NSDictionary {
                            if shoveler.count > 0 {
                                self.settingsData[0] = "Shovelers Information"
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        })
    }
}

// MARK: Message Composer delegate

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }

    func openEmail() {
        if MFMailComposeViewController.canSendMail() {
            let emailVC = MFMailComposeViewController()
            emailVC.mailComposeDelegate = self
            emailVC.setToRecipients(["support@shoveled.works"])
            emailVC.setSubject("Help needed!")
            self.present(emailVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "", message: "We don't currently support your email client. Please open your email and send your questions to support@shoveled.works", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
