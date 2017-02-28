//
//  RequestsListTableViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 2/12/17.
//  Copyright © 2017 Lucky Penguin. All rights reserved.
//

import UIKit
import Firebase

class RequestsListTableViewController: UITableViewController {

    fileprivate var ref = FIRDatabase.database().reference(withPath: "requests")
    fileprivate var requests = [ShovelRequest]()
    
    var newPriceString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = false
        self.tableView.tableFooterView = UIView()
        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.getShovelRequests()
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requests.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestsCellIdentifier", for: indexPath) as! RequestsListCell
        
        let request = self.requests[indexPath.row]
        cell.addressLabel?.text = request.address
        cell.dateCreatedLabel?.text = request.createdAt
        
        let convertedPrice: Float = Float(request.price)
        let updatedPrice = convertedPrice / 100
        self.newPriceString = String(updatedPrice)
        if let price = self.newPriceString {
            cell.priceLabel?.text = "$\(price)"
        }
        cell.statusLabel?.text = request.status
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let request = self.requests[indexPath.row]
            
            if request.status == "Active" {
                
                let alert: UIAlertController = UIAlertController(title: "Are you sure?", message: "Are you sure you want to remove your shovel request?\nYou will be issued a refund immediately.", preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
                let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                    
                    request.firebaseReference?.removeValue()
                    
                    StripeManager.sendRefundToCharge(chargeId: request.stripeChargeToken)                    
                }
                alert.addAction(cancelAction)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: { _ in })
            } else {
                request.firebaseReference?.removeValue()
            }
        }
    }
}

extension RequestsListTableViewController {
    
    // MARK: - Fetch Request
    func getShovelRequests() {
        self.showActivityIndicatory(self.view)
        self.ref.observe(.value, with: { snapshot in
            var requests: [ShovelRequest] = []
            for item in snapshot.children {
                let request = ShovelRequest(snapshot: item as? FIRDataSnapshot)
                requests.append(request)
                
                if request.status == "Completed" {
                    
                }
            }
            self.requests = requests
            DispatchQueue.main.async {
                self.hideActivityIndicator(self.view)
                self.tableView.reloadData()
            }
        })
    }
}
