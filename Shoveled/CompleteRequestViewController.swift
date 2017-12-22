//
//  CompleteRequestViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 1/24/17.
//  Copyright © 2017 Lucky Penguin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import MessageUI
import SendGrid

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
    var createdAt: String?
    var shovelRequest: ShovelRequest?

    lazy var ref = Database.database().reference(withPath: "requests")

    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.observeNotifications()
        self.getUserStripeId()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "COMPLETE REQUEST"
        self.rebuildTableViewDataAndRefresh()
    }

    func getUserStripeId() {
        shovelerRef.child("users").child(currentUserUid).observeSingleEvent(of: .value, with: { snapshot in
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
            var height: CGFloat
            if #available(iOS 11.0, *) {
                height = self.view.safeAreaInsets.top
            } else {
                height = 0
            }
            let navHeight = self.navigationController?.navigationBar.frame.height ?? 0
            let photoCellHeight = self.view.frame.height - (navHeight + 99 + height)
            return photoCellHeight
        }
    }

    @objc func displayCamera() {
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
        self.showActivityIndicatory(self.view)
        self.sendEmail { result in
            let requestFirebaseReference = self.shovelRequest?.firebaseReference
            requestFirebaseReference?.updateChildValues([
                StatusKey: "Completed",
                AcceptedByUserKey: currentUserEmail
                ]) { (error, _) in
                if error != nil {
                    return
                } else {
                    if result {
                        self.transferFunds()
                        self.sendCompletedImage()

                        let storyboard = UIStoryboard(name: "FullScreen", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "FullScreenViewController") as? FullScreenViewController

                        if let vc = vc {
                            self.hideActivityIndicator(self.view)
                            vc.message = "Congrats! Check to see if there are more requests."
                            self.present(vc, animated: true, completion: nil)
                        }
                    } else {
                        self.hideActivityIndicator(self.view)
                        let alert = UIAlertController(title: "There was an error completing your job.", message: "Please try sending it again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: .none))
                        self.present(alert, animated: true, completion: .none)
                    }
                }
            }
        }
    }

    func sendEmail(_ callBack: @escaping ((Bool)) -> Void) {
        guard let token = self.shovelRequest?.stripeChargeToken else {
            return
        }

        let personalization = Personalization(recipients: self.shovelRequest?.addedByUser ?? "")
        let contents = Content.emailBody(
            plain: "Sweet Day! Go out and check out your request. If you have any issues or for whatever reason your request was not completed, please use this reference ID: \(token) when contacting support.",
            html: "<h2>Sweet day!</h2><div>Go out and check out your request.\nIf you have any issues or for whatever reason your request was not completed, please use this reference ID: <b>\(token)</b> when contacting support.</div>"
         )
        let email = Email(
            personalizations: [personalization],
            from: Address(email: "noreply@shoveled.works"),
            content: contents,
            subject: "Shovel Request Completed!"
        )
        do {
            let path = documentsUrl.appendingPathComponent("shovelRequest.jpeg")
            let attachment = Attachment(
                filename: "shovelRequest.jpeg",
                content: try Data(contentsOf: path),
                disposition: .attachment,
                type: .jpeg,
                contentID: nil
            )
            email.attachments = [attachment]
            try Session.shared.send(request: email) { response in
                print(response?.httpUrlResponse?.statusCode ?? 400)
                if response?.httpUrlResponse?.statusCode == 202 {
                    callBack(true)
                } else {
                    callBack(false)
                }
            }
        } catch {
            print(error)
        }
    }

    func sendCompletedImage() {
        let storage = Storage.storage().reference().child("CompletedRequest.png")
        if let uploadData = UIImagePNGRepresentation((self.imageView?.image)!) {
            storage.putData(uploadData, metadata: nil)
        }
    }

    func transferFunds() {
        guard let price = self.shovelRequest?.priceToTransfer else {
            return
        }
        if let stripeId = self.stripeId, let chargeId = self.shovelRequest?.stripeChargeToken {
            StripeManager.transferFundsToAccount(amount: price, destination: stripeId, chargeId: chargeId)
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
            self.saveImage(imageName: "shovelRequest.jpeg")
            self.didImagePickerDismiss = true
        }
    }

    func saveImage(imageName: String) {
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        guard let image = self.imageView?.image else {
            return
        }
        guard let data = UIImagePNGRepresentation(image) else {
            return
        }
        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
    }

    private func loadImage() -> UIImage? {
        let fileURL = documentsUrl.appendingPathComponent("shovelRequest.jpeg")
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
}

// MARK: Notification Center

extension CompleteRequestViewController {

    func observeNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(CompleteRequestViewController.dismissView), name: .fullScreenDidDisapear, object: nil)
    }

    @objc func dismissView(_ notification: Notification) {
        self.dismiss(animated: true, completion: nil)
    }
}
