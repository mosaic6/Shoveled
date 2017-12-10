//
//  RequestsListTableViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 2/12/17.
//  Copyright © 2017 Lucky Penguin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class RequestsListTableViewController: UITableViewController {

    fileprivate var ref = Database.database().reference(withPath: "requests")
    fileprivate var requests = [ShovelRequest]()
    fileprivate var canEditCell: Bool = true
    var newPriceString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.requests)

        self.navigationController?.navigationBar.isHidden = false
        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.emptyStateTableFooterView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        if !self.canEditCell {
            cell.isUserInteractionEnabled = false
        }
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
        let request = self.requests[indexPath.row]
        if request.status == "Complete" {
            return false
        } else {
            return true
        }
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let request = self.requests[indexPath.row]

            if request.status == "Active" {
                let alert: UIAlertController = UIAlertController(title: "Are you sure?", message: "Are you sure you want to remove your shovel request?\nYou will be issued a refund immediately.", preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
                let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action in
                    request.firebaseReference?.removeValue()
                    self.requests.remove(at: indexPath.row)
                    StripeManager.sendRefundToCharge(chargeId: request.stripeChargeToken)
                }
                alert.addAction(cancelAction)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: { _ in })
            }
        }
    }
}

extension RequestsListTableViewController {

    // MARK: - Fetch Request
    func getShovelRequests() {
        self.showActivityIndicatory(self.view)
        self.ref.observe(.value, with: { snapshot in
            for item in snapshot.children {
                let request = ShovelRequest(snapshot: item as? DataSnapshot)
                self.requests.append(request)
                if request.status == "Completed" {
                    self.canEditCell = false
                }
            }
            DispatchQueue.main.async {
                self.hideActivityIndicator(self.view)
                self.tableView.reloadData()
            }
        })
    }
}

extension RequestsListTableViewController {

    func emptyStateTableFooterView() {
        if self.requests.isEmpty {
            let customView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
            let sunImage = UIImage(named: "Sun")
            let imageView = UIImageView(image: sunImage)
            imageView.frame = CGRect(x: (self.view.frame.size.width / 2) - 25, y: (self.view.frame.size.height / 2) - 50, width: 50, height: 50)

            imageView.contentMode = .scaleAspectFit
            customView.addSubview(imageView)
            self.tableView.isScrollEnabled = false
            self.tableView.tableFooterView = customView
        } else {
            self.tableView.tableFooterView = UIView()
        }
        self.tableView.reloadData()
    }
}
