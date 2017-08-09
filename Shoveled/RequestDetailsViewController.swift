//
//  RequestDetailsViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 1/17/17.
//  Copyright © 2017 Lucky Penguin. All rights reserved.
//

import UIKit
import Firebase

class RequestDetailsViewController: UITableViewController {

    fileprivate enum CellIdentifier: String {
        case addressCell = "addressCell"
        case descriptionCell = "descriptionCell"
        case moreInfoCell = "moreInfoCell"
        case priceCell = "priceCell"
        case acceptCell = "acceptCell"
        case acceptedCell = "acceptedCell"
        case completeCell = "completeCell"
        case cancelCell = "cancelCell"
        case shovelerSignUpCell = "shovelerSignUpCell"
    }

    fileprivate enum RequestStatus: String {
        case active = "Active"
        case accepted = "Accepted"
        case completed = "Completed"
    }

    fileprivate var tableViewData: [[CellIdentifier]] = []
    fileprivate var addressCell: RequestDetailCell?
    fileprivate var descriptionCell: RequestDetailCell?
    fileprivate var moreInfoCell: RequestDetailCell?
    fileprivate var priceCell: RequestDetailCell?
    fileprivate var acceptCell: RequestDetailCell?
    fileprivate var acceptedCell: RequestDetailCell?
    fileprivate var completeCell: RequestDetailCell?
    fileprivate var cancelCell: RequestDetailCell?
    fileprivate var shovelerSignUpCell: RequestDetailCell?

    var status: String?
    var newPriceString: String?
    var isShoveler: Bool = false
    var shovelRequest: ShovelRequest?
    fileprivate var stripeId: String?

    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference(withPath: "requests")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "REQUEST DETAILS"
        self.rebuildTableViewDataAndRefresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = ""
    }

    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    fileprivate func rebuildTableViewDataAndRefresh() {
        let tableViewData: [[CellIdentifier]]

        tableViewData = self.tableViewDataForRequest()

        self.tableViewData = tableViewData
        self.tableView?.tableFooterView = UIView()
        self.tableView?.reloadData()
    }

    fileprivate func tableViewDataForRequest() -> [[CellIdentifier]] {
        var tableViewData: [[CellIdentifier]] = []
        var requestData: [CellIdentifier] = []

        requestData.append(.addressCell)
        requestData.append(.descriptionCell)
        requestData.append(.moreInfoCell)
        requestData.append(.priceCell)

        if currentUserEmail == shovelRequest?.addedByUser {
            requestData.append(.cancelCell)
            tableViewData.append(requestData)
            return tableViewData
        }

        if !self.isShoveler && currentUserEmail != shovelRequest?.addedByUser && shovelRequest?.status != RequestStatus.accepted.rawValue {
            requestData.append(.shovelerSignUpCell)
            tableViewData.append(requestData)
            return tableViewData
        }

        if shovelRequest?.status == RequestStatus.active.rawValue && !(currentUserEmail == shovelRequest?.addedByUser) {
            requestData.append(.acceptCell)
            tableViewData.append(requestData)
            return tableViewData
        }

        if shovelRequest?.status == RequestStatus.accepted.rawValue && currentUserEmail == shovelRequest?.acceptedByUser {
            requestData.append(.completeCell)
            tableViewData.append(requestData)
            return tableViewData
        } else {
            requestData.append(.acceptedCell)
        }

        if shovelRequest?.status == RequestStatus.completed.rawValue {
            self.dismiss(animated: true, completion: nil)
        }

        tableViewData.append(requestData)

        return tableViewData
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellIdentifier = self.identifier(at: indexPath) else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.rawValue)!

        switch cellIdentifier {
        case .addressCell:
            let addressCell = cell as! RequestDetailCell
            addressCell.addressLabel?.text = shovelRequest?.address.uppercased()
            self.addressCell = addressCell
        case .descriptionCell:
            let descriptionCell = cell as! RequestDetailCell
            descriptionCell.descriptionLabel?.text = shovelRequest?.details.uppercased()
            self.descriptionCell = descriptionCell
        case .moreInfoCell:
            let moreInfoCell = cell as! RequestDetailCell
            if shovelRequest?.otherInfo == "" {
                moreInfoCell.moreInfoLabel?.text = "No extra details".uppercased()
                break
            } else {
                moreInfoCell.moreInfoLabel?.text = shovelRequest?.otherInfo.uppercased()
            }
            self.moreInfoCell = moreInfoCell
        case .priceCell:
            let priceCell = cell as! RequestDetailCell
            if let price = shovelRequest?.price {
                let convertedPrice: Float = Float(price)
                let percentageChange: Float = Float(convertedPrice) * 0.10
                let updatedPrice = (convertedPrice - percentageChange) / 100
                self.newPriceString = String(updatedPrice)
                if let price = self.newPriceString {
                    priceCell.priceLabel?.text = "$\(price)".uppercased()
                }
            }
            self.priceCell = priceCell
        case .acceptCell:
            let acceptCell = cell as! RequestDetailCell
            acceptCell.acceptButton?.addTarget(self, action: #selector(RequestDetailsViewController.acceptRequest), for: .touchUpInside)
            self.acceptCell = acceptCell
        case .acceptedCell:
            let acceptedCell = cell as! RequestDetailCell
            self.acceptedCell = acceptedCell
        case .completeCell:
            let completeCell = cell as! RequestDetailCell
            completeCell.completeButton?.addTarget(self, action: #selector(RequestDetailsViewController.showCompleteRequest), for: .touchUpInside)
            self.completeCell = completeCell
        case .cancelCell:
            let cancelCell = cell as! RequestDetailCell
            cancelCell.cancelButton?.addTarget(self, action: #selector(RequestDetailsViewController.deleteRequest), for: .touchUpInside)
            self.cancelCell = cancelCell
        case .shovelerSignUpCell:
            let shovelerSignUpCell = cell as! RequestDetailCell
            shovelerSignUpCell.shovelerSignUpButton?.addTarget(self, action: #selector(RequestDetailsViewController.openShovelerSignUpViewController), for: .touchUpInside)
            self.shovelerSignUpCell = shovelerSignUpCell
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

   // MARK: - Navigation

    func showCompleteRequest() {
        let completeRequestView = self.storyboard?.instantiateViewController(withIdentifier: "CompleteRequestViewController") as? CompleteRequestViewController
        if let completeRequestVC = completeRequestView {
            completeRequestVC.shovelRequest = shovelRequest
            self.navigationController?.pushViewController(completeRequestVC, animated: true)
        } else {
            return
        }
    }

}

// MARK: Shoveler Delegate

extension RequestDetailsViewController {

    fileprivate func isUserShoveler() {
        shovelerRef?.child("users").child(currentUserUid).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let shoveler = value?["shoveler"] as? NSDictionary ?? [:]
            if let stripeId = shoveler.object(forKey: "stripeId") as? String, stripeId != "" {
                self.stripeId = stripeId
            }
        })
    }

    func openShovelerSignUpViewController() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SettingsTableViewController") as? SettingsTableViewController
        let nav: UINavigationController = UINavigationController(rootViewController: vc!)
        self.present(nav, animated: true, completion: nil)
    }
}

// MARK: Shovel Request Delegate

extension RequestDetailsViewController {

    // MARK: Delete Request

    func deleteRequest() {
        let alert: UIAlertController = UIAlertController(title: "Are you sure?", message: "Are you sure you want to remove your shovel request?\nYou will be issued a refund immediately.", preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { (action) in

            self.shovelRequest?.firebaseReference?.removeValue()
            self.issueRefund()
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: { _ in })
    }

    // MARK: Accept Request

    func acceptRequest() {
        actInd.startAnimating()

        let alert: UIAlertController = UIAlertController(title: "Congrats!", message: "Once the job is complete please take a photo of your work and submit it.", preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let okAction: UIAlertAction = UIAlertAction(title: "Let's Go", style: .default) { (action) in

            let requestFirebaseReference = self.shovelRequest?.firebaseReference
            requestFirebaseReference?.updateChildValues([
                StatusKey: "Accepted",
                AcceptedByUserKey: currentUserEmail
                ])

            actInd.stopAnimating()

            self.showCompleteRequest()

            if let addedByUser = self.shovelRequest?.addedByUser {
                if let token = self.shovelRequest?.stripeChargeToken {
                    EmailManager.sharedInstance.sendConfirmationEmail(email: addedByUser, toName: "", subject: "Your shoveled request has been accepted!", text: "<html><div>\(currentUserEmail) has accepted your shovel request, and in enroute to complete your request. Once your request has been competed you will receive a confirmation email. Use reference ID: <b>\(token)</b> when contacting support.</div></html>")
                    
                    let address = self.shovelRequest?.address ?? ""
                    EmailManager.sharedInstance.sendConfirmationEmail(email: currentUserEmail, toName: "", subject: "Time to get Shoveling!", text: "<html><div>You've accepted a shoveling request at \(address). Please complete this request in a timely manner. If you have any issues please reach out to support@shoveled.works.</div></html>")
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: { _ in })
    }

    // MARK: Issue Refund
    func issueRefund() {
        if let chargeId = shovelRequest?.stripeChargeToken {
            StripeManager.sendRefundToCharge(chargeId: chargeId)
        }
    }
}
