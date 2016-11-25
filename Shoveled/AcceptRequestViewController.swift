//
//  AcceptRequestViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 1/16/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

protocol CompletedRequestDelegate {
    func updateRequest()
}

class AcceptRequestViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var shovelTimeLabel: UILabel!
    @IBOutlet weak var acceptBtn: ShoveledButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var completeJobBtn: UIButton!
    @IBOutlet weak var signUpAsShovelerBtn: UIButton?

    var closeModalBtn: UIButton!
    var imageView: UIImageView!
    var imagePickerView: UIImagePickerController!
    var uploadCompletedJobBtn: UIButton!
    var instructionsLabel: UILabel!

    var completeRequestBtn: UIButton!

    var titleString: String?
    var addressString: String?
    var descriptionString: String?
    var priceString: String?
    var otherInfoString: String?
    var latitude: NSNumber?
    var longitude: NSNumber?
    var addedByUser: String?
    var otherInfo: String?
    var status: String?
    var id: String?
    var createdAt: String?
    var acceptedByUser: String?
    var stripeChargeToken: String?
    var completeRequestView = CompleteRequestView()

    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference(withPath: "requests")
    let currentUser = FIRAuth.auth()?.currentUser?.email

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func configureView() {
        cancelBtn.isHidden = true
        completeJobBtn.isHidden = true
        completeJobBtn.layer.cornerRadius = 5.0
        completeJobBtn.addTarget(self, action: #selector(showCompleteRequestView), for: .touchUpInside)

        guard let description = descriptionString else { return }
        guard let price = priceString else { return }

        self.titleLabel?.text = self.titleString?.uppercased()
        self.addressLabel.text = self.addressString?.uppercased()
        self.descriptionLabel.text = "Please Shovel: \(description)".uppercased()
        self.priceLabel.text = "Will Pay: $\(price).00".uppercased()
        if let moreInfoString = self.otherInfoString, moreInfoString == "" {
            shovelTimeLabel.text = "No more details for you!".uppercased()
        } else {
            shovelTimeLabel.text = "Other Info: \(otherInfoString)".uppercased()
        }

        guard let rStatus = status else { return }
        if rStatus == "Accepted" {
            acceptBtn.setTitle("In Progress", for: UIControlState())
            acceptBtn.backgroundColor = UIColor(red: 235.0 / 255.0, green: 135.0 / 255.0, blue: 35.0 / 255.0, alpha: 0.8)
            acceptBtn.isEnabled = false
            if currentUser == acceptedByUser {
                completeJobBtn.isHidden = false
            }
        } else if rStatus == "Completed" {
            acceptBtn.setTitle("Completed", for: UIControlState())
            acceptBtn.backgroundColor = UIColor(red: 35.0 / 255.0, green: 135.0 / 255.0, blue: 235.0 / 255.0, alpha: 0.8)
            acceptBtn.isEnabled = false
        } else {
            acceptBtn.setTitle("Accept", for: UIControlState())
        }

        if currentUser == addedByUser {
            acceptBtn.isHidden = true

            cancelBtn.isHidden = false
        }

        self.closeModalBtn = UIButton(frame: CGRect(x: 20, y: 28, width: 28.0, height: 28.0))
        self.closeModalBtn.setImage(UIImage(named: "Close"), for: .normal)
        self.closeModalBtn.addTarget(self, action: #selector(AcceptRequestViewController.closeModal), for: .touchUpInside)

        self.imagePickerView = UIImagePickerController()
        self.imageView = UIImageView(frame: CGRect(x: 0, y: 50, width: self.view.frame.width, height: 275.0))
        self.imageView.image = UIImage(named: "camera")
        self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(displayCamera)))
        self.imageView.isUserInteractionEnabled = true
        self.imageView.contentMode = .center
        self.imageView.layer.cornerRadius = 5.0
        self.imageView.setNeedsDisplay()

        self.uploadCompletedJobBtn = UIButton(frame: CGRect(x: 10, y: self.view.bounds.height - 70, width: self.view.frame.width - 20, height: 55.0))
        self.uploadCompletedJobBtn.setTitle("Send Completed Job", for: .normal)
        self.uploadCompletedJobBtn.backgroundColor = UIColor(red: 35.0 / 255.0, green: 135.0 / 255.0, blue: 235.0 / 255.0, alpha: 0.8)
        self.uploadCompletedJobBtn.layer.cornerRadius = 5.0
        self.uploadCompletedJobBtn.isHidden = true
        self.uploadCompletedJobBtn.addTarget(self, action: #selector(sendCompletedJob), for: .touchUpInside)

        self.instructionsLabel = UILabel(frame: CGRect(x: 10, y: 380, width: self.view.frame.width - 20, height: 50))
        self.instructionsLabel.font = UIFont(name: "Marvel", size: 18)
        self.instructionsLabel.numberOfLines = 3
        self.instructionsLabel.textAlignment = NSTextAlignment.center
        self.instructionsLabel.text = "Once your job is complete, please upload a photo and you'll get paid 💰"

        self.completeRequestView.center.y -= view.bounds.height
        self.completeRequestView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(completeRequestView)
        self.completeRequestView.addSubview(imageView)
        self.completeRequestView.addSubview(uploadCompletedJobBtn)
        self.completeRequestView.addSubview(instructionsLabel)
        self.completeRequestView.addSubview(closeModalBtn)
        self.completeRequestView.isHidden = true

        self.getConnectedAccountEmails()
    }

    func showCompleteRequestView() {
        self.completeRequestView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 5.0,
                                   options: UIViewAnimationOptions.allowUserInteraction, animations: {

            self.completeRequestView.isHidden = false
            self.completeRequestView.center.y += 0
            self.completeRequestView.transform = CGAffineTransform.identity
        }, completion: nil)
    }

    @IBAction func cancelRequest(_ sender: AnyObject) {
        deleteRequest()
    }

    @IBAction func acceptRequest(_ sender: AnyObject) {

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
                                            "acceptedByUser": currentUser! as AnyObject,
                                            "stripeChargeToken": self.stripeChargeToken as AnyObject]

        let childUpdates = ["/\(requestId)": request]
        ref.updateChildValues(childUpdates)

        actInd.stopAnimating()

        let alert: UIAlertController = UIAlertController(title: "Congrats!", message: "Once the job is complete please take a photo of your work and submit it.", preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let okAction: UIAlertAction = UIAlertAction(title: "Let's Go", style: .default) { (action) in
            self.ref.updateChildValues(childUpdates)

            if let addedByUser = self.addedByUser, let currentUser = self.currentUser {
                if let token = self.stripeChargeToken {
                    EmailManager.sharedInstance.sendConfirmationEmail(email: addedByUser, toName: "", subject: "Your shoveled request has been accepted!", text: "\(currentUser) has accepted your shovel request, and in enroute to complete your request. Once your request has been competed you will receive a confirmation email. Use reference ID: <b>\(token)</b> when contacting support.")
                }
            }

            self.showCompleteRequestView()
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: { _ in })
    }

    @IBAction func dismissView(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

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

    func issueRefund() {
        if let chargeId = self.stripeChargeToken {
            StripeManager.sendRefundToCharge(chargeId: chargeId)
        }
    }

    func closeModal() {
        UIView.animate(withDuration: 3.0, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.0,
                       options: UIViewAnimationOptions.allowUserInteraction, animations: {

                        self.completeRequestView.isHidden = true
        })
    }

    func displayCamera() {
        imagePickerView.delegate = self

        #if(arch(i386) || arch(x86_64)) && os(iOS)
        imagePickerView.sourceType = .photoLibrary
            #else
            imagePickerView.sourceType = .camera
            #endif
        present(imagePickerView, animated: true, completion: nil)
    }

    func sendCompletedJob() {

        self.showActivityIndicatory(self.completeRequestView)

        guard let requestId = id,
            let address = addressString,
            let description = descriptionString
            else { return }
        let price: Int? = Int(priceString!)

        let request: [String: AnyObject] = ["status": "Completed" as AnyObject,
                                            "address": address as AnyObject,
                                            "longitude": self.longitude!,
                                            "latitude": self.latitude!,
                                            "details": description as AnyObject,
                                            "addedByUser": self.addedByUser! as AnyObject,
                                            "otherInfo": "" as AnyObject,
                                            "price": price! as AnyObject,
                                            "id": self.id! as AnyObject,
                                            "createdAt": self.createdAt! as AnyObject,
                                            "acceptedByUser": self.currentUser! as AnyObject,
                                            "stripeChargeToken": self.stripeChargeToken as AnyObject]

        let childUpdates = ["/\(requestId)": request]
        self.ref.updateChildValues(childUpdates) { (error, ref) in
            if error != nil {
                return
            } else {
                self.hideActivityIndicator(self.completeRequestView)

                let alert: UIAlertController = UIAlertController(title: "Congrats!", message: "Check to see if there are more requests.", preferredStyle: .alert)
                let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: { _ in })

                if let addedByUser = self.addedByUser {
                    if let token = self.stripeChargeToken {
                        EmailManager.sharedInstance.sendConfirmationEmail(email: addedByUser, toName: "", subject: "Your shoveled request has been completed!", text: "Sweet day! Go out and check out your request.\nIf you have any issues or for whatever reason your request was not completed, please use this reference ID: <b>\(token)</b> when contacting support.")
                    }
                }
            }
        }

        let storage = FIRStorage.storage().reference().child("\(requestId)-completedJob.png")
        if let uploadData = UIImagePNGRepresentation(self.imageView.image!) {
            storage.put(uploadData, metadata: nil) { (metaData, error) in
                if error != nil {
                    return
                }
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {

        imagePickerView.dismiss(animated: true) {
            if info.isEmpty {
                return
            } else {
                self.imageView.contentMode = UIViewContentMode.scaleAspectFit
                self.imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
                self.uploadCompletedJobBtn.isHidden = false
            }
        }
    }
}

extension AcceptRequestViewController {
    func saveImageDocumentDirectory() {
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("completedJob.jpg")
        let image = UIImage(named: "completedJob.jpg")
        let imageData = UIImageJPEGRepresentation(image!, 0.5)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
    }

    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func getImage() -> UIImage {
        let fileManager = FileManager.default
        let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent("completedJob.jpg")
        if fileManager.fileExists(atPath: imagePAth) {
            self.imageView.image = UIImage(contentsOfFile: imagePAth)
            return self.imageView.image!
        }
        return self.imageView.image!
    }

    func createDirectory() {
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("customDirectory")
        if !fileManager.fileExists(atPath: paths) {
            try! fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
        }
    }
}

extension AcceptRequestViewController {

    fileprivate func getConnectedAccountEmails() {
        StripeManager.getConnectedAccounts { (stripeEmail) in
            if self.currentUser == stripeEmail {
                DispatchQueue.main.async {
                    self.signUpAsShovelerBtn?.isHidden = true
                }
            }
        }
    }
}

extension FileManager {
    class func documentsDir() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }

    class func cachesDir() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
}
