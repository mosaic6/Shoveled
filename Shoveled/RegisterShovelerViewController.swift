//
//  RegisterShovelerViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 1/15/18.
//  Copyright © 2018 Lucky Penguin. All rights reserved.
//

import UIKit
import Firebase

class RegisterShovelerViewController: UIViewController {

    // MARK: Variables

    private var tableViewData: [[CellIdentifier]] = []
    var basicInfoHeaderCell: RegisterShovelerCell?
    var firstNameCell: RegisterShovelerCell?
    var lastNameCell: RegisterShovelerCell?
    var emailAddressCell: RegisterShovelerCell?
    var passwordCell: RegisterShovelerCell?

    var firstName: String? {
        return self.firstNameCell?.firstNameTextField?.text
    }

    var lastName: String? {
        return self.lastNameCell?.lastNameTextField?.text
    }

    var emailAddress: String? {
        return self.emailAddressCell?.emailAddressTextField?.text
    }

    var password: String? {
        return self.passwordCell?.passwordTextField?.text
    }

    lazy var ref = Database.database().reference()

    // MARK: Outlets

    @IBOutlet weak var tableView: UITableView?

    // MARK: Actions

    @IBAction func closeView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

    // MARK: View Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        self.firstNameCell?.firstNameTextField?.delegate = self
        self.lastNameCell?.lastNameTextField?.delegate = self
        self.emailAddressCell?.emailAddressTextField?.delegate = self
        self.passwordCell?.passwordTextField?.delegate = self

        self.tableView?.tableFooterView = UIView()
        self.rebuildTableViewDataAndRefresh()
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

        var cellData: [CellIdentifier] = []

        cellData.append(.basicInfoHeaderCell)
        cellData.append(.firstNameCell)
        cellData.append(.lastNameCell)
        cellData.append(.emailCell)
        cellData.append(.passwordCell)

        tableViewData.append(cellData)

        return tableViewData
    }
}

// MARK: TableView Delegate and DataSource

extension RegisterShovelerViewController: UITableViewDataSource, UITableViewDelegate {

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
        case .basicInfoHeaderCell:
            let basicInfoHeaderCell = cell as! RegisterShovelerCell
            self.basicInfoHeaderCell = basicInfoHeaderCell
        case .firstNameCell:
            let firstNameCell = cell as! RegisterShovelerCell
            self.firstNameCell = firstNameCell
        case .lastNameCell:
            let lastNameCell = cell as! RegisterShovelerCell
            self.lastNameCell = lastNameCell
        case .emailCell:
            let emailCell = cell as! RegisterShovelerCell
            self.emailAddressCell = emailCell
        case .passwordCell:
            let passwordCell = cell as! RegisterShovelerCell
            self.passwordCell = passwordCell
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellIdentifier = self.identifier(at: indexPath) else {
            return 0
        }

        switch cellIdentifier {
        case .basicInfoHeaderCell:
            return 100.0

        default:
            return 50.0
        }
    }
}

// MARK: CellIdentifiers

extension RegisterShovelerViewController {

    enum CellIdentifier: String {
        case basicInfoHeaderCell
        case firstNameCell
        case lastNameCell
        case emailCell
        case passwordCell
    }
}
