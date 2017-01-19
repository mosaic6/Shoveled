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
    
    var addressString: String?    
    var descriptionString: String?
    var moreInfoString: String?
    var priceString: String?
    var latitude: NSNumber?
    var longitude: NSNumber?
    var addedByUser: String?
    var otherInfo: String?
    var status: String?
    var id: String?
    var createdAt: String?
    var acceptedByUser: String?
    var stripeChargeToken: String?
    var newPriceString: String?
    
    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference(withPath: "requests")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        self.rebuildTableViewDataAndRefresh()
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
        
        if currentUserEmail == self.addedByUser {
            requestData.append(.cancelCell)
            tableViewData.append(requestData)
            return tableViewData
        }
        
        if self.status == RequestStatus.active.rawValue && !(currentUserEmail == self.addedByUser) {
            requestData.append(.acceptCell)
            tableViewData.append(requestData)
            return tableViewData
        }
        
        if self.status == RequestStatus.accepted.rawValue && currentUserEmail == self.acceptedByUser {
            requestData.append(.completeCell)
            tableViewData.append(requestData)
            return tableViewData
        } else {
            requestData.append(.acceptedCell)
        }
        
        if self.status == RequestStatus.completed.rawValue {
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
            addressCell.addressLabel?.text = addressString?.uppercased()
            self.addressCell = addressCell
        case .descriptionCell:
            let descriptionCell = cell as! RequestDetailCell
            descriptionCell.descriptionLabel?.text = descriptionString?.uppercased()
            self.descriptionCell = descriptionCell
        case .moreInfoCell:
            let moreInfoCell = cell as! RequestDetailCell
            if self.moreInfoString == "" {
                moreInfoCell.moreInfoLabel?.text = "No extra details".uppercased()
                break
            } else {
                moreInfoCell.moreInfoLabel?.text = moreInfoString?.uppercased()
            }
            self.moreInfoCell = moreInfoCell
        case .priceCell:
            let priceCell = cell as! RequestDetailCell
            let price = self.priceString
            let convertedPrice: Float = Float(price!)!
            let percentageChange: Float = Float(convertedPrice) * 0.10
            let updatedPrice = (convertedPrice - percentageChange) / 100
            self.newPriceString = String(updatedPrice)
            if let price = self.newPriceString {
                priceCell.priceLabel?.text = "$\(price)".uppercased()
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
//            completeCell.completeButton?.addTarget(self, action: #selector(RequestDetailsViewController.completeRequest), for: .touchUpInside)
            self.completeCell = completeCell
        case .cancelCell:
            let cancelCell = cell as! RequestDetailCell
            cancelCell.cancelButton?.addTarget(self, action: #selector(RequestDetailsViewController.deleteRequest), for: .touchUpInside)
            self.cancelCell = cancelCell
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

   // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}

// MARK: Shovel Request Delegate

extension RequestDetailsViewController {
    
    // MARK: Delete Request
    
    func deleteRequest() {
        let alert: UIAlertController = UIAlertController(title: "Are you sure?", message: "Are you sure you want to remove your shovel request?\nYou will be issued a refund immediately.", preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            
            guard let requestId = self.id else { return }
            let requestToDelete = self.ref.child(requestId)
            requestToDelete.removeValue()
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
        
        guard let requestId = id,
            let address = addressString,
            let description = descriptionString
            else { return }
        let price: Int? = Int(priceString!)
        
        let request: [String: AnyObject] = ["status": "Accepted" as AnyObject,
                                            "address": address as AnyObject,
                                            "longitude": longitude!,
                                            "latitude": latitude!,
                                            "details": description as AnyObject,
                                            "addedByUser": addedByUser! as AnyObject,
                                            "otherInfo": "" as AnyObject,
                                            "price": price! as AnyObject,
                                            "id": id! as AnyObject,
                                            "createdAt": createdAt! as AnyObject,
                                            "acceptedByUser": currentUserEmail as AnyObject,
                                            "stripeChargeToken": self.stripeChargeToken as AnyObject]
        
        
        let alert: UIAlertController = UIAlertController(title: "Congrats!", message: "Once the job is complete please take a photo of your work and submit it.", preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let okAction: UIAlertAction = UIAlertAction(title: "Let's Go", style: .default) { (action) in
            let childUpdates = ["/\(requestId)": request]
            self.ref.updateChildValues(childUpdates)
            actInd.stopAnimating()
            
            if let addedByUser = self.addedByUser {
                if let token = self.stripeChargeToken {
                    EmailManager.sharedInstance.sendConfirmationEmail(email: addedByUser, toName: "", subject: "Your shoveled request has been accepted!", text: "<html><div>\(currentUserEmail) has accepted your shovel request, and in enroute to complete your request. Once your request has been competed you will receive a confirmation email. Use reference ID: <b>\(token)</b> when contacting support.</div></html>")
                    
                    EmailManager.sharedInstance.sendConfirmationEmail(email: currentUserEmail, toName: "", subject: "Time to get Shoveling!", text: "<html><div>You've accepted a shoveling request at \(address). Please complete this request in a timely manner. If you have any issues please reach out to support@shoveled.works.</div></html>")
                }
            }
            // NAVIGATE TO COMPLETE REQUEST VIEW
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: { _ in })
    }
    
    // MARK: Issue Refund
    func issueRefund() {
        if let chargeId = self.stripeChargeToken {
            StripeManager.sendRefundToCharge(chargeId: chargeId)
        }
    }
}