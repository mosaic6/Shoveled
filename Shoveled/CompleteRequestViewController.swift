//
//  CompleteRequestViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 1/24/17.
//  Copyright © 2017 Lucky Penguin. All rights reserved.
//

import UIKit
import Firebase

class CompleteRequestViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    fileprivate enum CellIdentifier: String {
        case infoCell = "infoCell"
        case photoViewCell = "photoViewCell"
        case takePhotoCell = "takePhotoCell"
        case sendJobCell = "sendJobCell"
    }

    fileprivate var tableViewData: [[CellIdentifier]] = []
    fileprivate var infoCell: CompleteRequestCell?
    fileprivate var photoViewCell: CompleteRequestCell?
    fileprivate var takePhotoCell: CompleteRequestCell?
    fileprivate var sendJobCell: CompleteRequestCell?

    fileprivate var imagePickerView: UIImagePickerController? = UIImagePickerController()
    fileprivate var didImagePickerDismiss = false
    fileprivate var imageView: UIImageView?
    var stripeId: String?
    var id: String?
    var priceString: String?
    var latitude: NSNumber?
    var longitude: NSNumber?
    var addedByUser: String?
    var createdAt: String?
    var stripeChargeToken: String?
    var shovelRequest: ShovelRequest?

    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference(withPath: "requests")

    override func viewDidLoad() {
        super.viewDidLoad()

        self.getUserStripeId()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "COMPLETE REQUEST"
        self.rebuildTableViewDataAndRefresh()
    }

    func getUserStripeId() {
        shovelerRef?.child("users").child(currentUserUid).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let shoveler = value?["shoveler"] as? NSDictionary ?? [:]
            if let stripeId = shoveler.object(forKey: "stripeId") as? String, stripeId != "" {
                self.stripeId = stripeId
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewData[section].count
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

        requestData.append(.infoCell)
        requestData.append(.photoViewCell)
        requestData.append(.takePhotoCell)

        if self.didImagePickerDismiss {
            requestData.append(.sendJobCell)
        }

        tableViewData.append(requestData)

        return tableViewData
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
        case .infoCell:
            let infoCell = cell as! CompleteRequestCell
            self.infoCell = infoCell
        case .photoViewCell:
            let photoViewCell = cell as! CompleteRequestCell
            self.photoViewCell = photoViewCell
        case .takePhotoCell:
            let takePhotoCell = cell as! CompleteRequestCell
            takePhotoCell.takePhotoButton?.addTarget(self, action: #selector(CompleteRequestViewController.displayCamera), for: .touchUpInside)
            self.takePhotoCell = takePhotoCell
        case .sendJobCell:
            let sendJobCell = cell as! CompleteRequestCell
            sendJobCell.sendCompletedJobButton?.addTarget(self, action: #selector(CompleteRequestViewController.sendCompletedJob), for: .touchUpInside)
            self.sendJobCell = sendJobCell
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellIdentifier = self.identifier(at: indexPath) else {
            return 0
        }

        switch cellIdentifier {
        case .infoCell, .takePhotoCell:
            return 44.0
        case .sendJobCell:
            return 55.0
        case .photoViewCell:
            return 200.0
        }
    }

    func displayCamera() {
        guard let imagePickerView = self.imagePickerView else { return }
        imagePickerView.delegate = self
        #if(arch(i386) || arch(x86_64)) && os(iOS)
            imagePickerView.sourceType = .photoLibrary
        #else
            imagePickerView.sourceType = .camera
        #endif
        present(imagePickerView, animated: true, completion: nil)
    }

    func sendCompletedJob() {
        let requestFirebaseReference = self.shovelRequest?.firebaseReference
        requestFirebaseReference?.updateChildValues([
            StatusKey: "Completed",
            AcceptedByUserKey: currentUserEmail
            ]) { (error, ref) in
            if error != nil {
                return
            } else {
                let alert: UIAlertController = UIAlertController(title: "Congrats!", message: "Check to see if there are more requests.", preferredStyle: .alert)
                let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                    self.sendCompletedJob()
                    self.transferFunds()
                    self.sendCompletedImage()
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: { _ in })
                if let addedByUser = self.addedByUser {
                    if let token = self.stripeChargeToken {
                        EmailManager.sharedInstance.sendConfirmationEmail(email: addedByUser, toName: "", subject: "Your shoveled request has been completed!", text: "<html><div>Sweet day! Go out and check out your request.\nIf you have any issues or for whatever reason your request was not completed, please use this reference ID: <b>\(token)</b> when contacting support.<br/></div></html>")
                    }
                }
            }
        }
    }

    func sendCompletedImage() {
        let storage = FIRStorage.storage().reference().child("CompletedRequest.png")
        if let uploadData = UIImagePNGRepresentation((self.imageView?.image)!) {
            storage.put(uploadData, metadata: nil) { (metaData, error) in
                if error != nil {
                    return
                }
            }
        }
    }

    func transferFunds() {
        if let newPriceString = self.priceString {
            let convertedPrice: Float = Float(newPriceString)! * 100
            let percentageChange: Float = Float(convertedPrice) * 0.10
            let updatedPrice: Int = Int(convertedPrice - percentageChange) / 100
            let stringAmount: String = String(updatedPrice)

            if let stripeId = self.stripeId, let chargeId = self.stripeChargeToken {
                StripeManager.transferFundsToAccount(amount: stringAmount, destination: stripeId, chargeId: chargeId)
            }
        }
    }

    // MARK: Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        self.imagePickerView?.dismiss(animated: true)
        if info.isEmpty {
            print("There was an error loading your image")
        } else {
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
            self.imageView = photoViewCell?.completedJobImageView
            self.imageView?.contentMode = UIViewContentMode.scaleAspectFill
            self.imageView?.image = image

            self.didImagePickerDismiss = true
        }
    }
}
