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

class AcceptRequestViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var shovelTimeLabel: UILabel!
    @IBOutlet weak var acceptBtn: ShoveledButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var closeModalBtn: UIButton!
    var imageView: UIImageView!
    var imagePickerView: UIImagePickerController!
    var uploadCompletedJobBtn: UIButton!
    var instructionsLabel: UILabel!
    
    var completeRequestBtn: UIButton!
    
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
    var completeRequestView = CompleteRequestView()
    
    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference(withPath: "requests")
    let currentUser = FIRAuth.auth()?.currentUser?.email
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    func configureView() {
        
        cancelBtn.isHidden = true
        
        guard let description = descriptionString else { return }
        guard let price = priceString else { return }
        
        addressLabel.text = addressString?.uppercased()
        descriptionLabel.text = "Please Shovel: \(description)".uppercased()
        priceLabel.text = "Will Pay: $\(price).00".uppercased()
        if let moreInfoString = otherInfoString , moreInfoString == "" {
            shovelTimeLabel.text = "No more details for you!".uppercased()
        }
        else {
            shovelTimeLabel.text = "Other Info: \(otherInfoString)".uppercased()
        }
        
        guard let rStatus = status else { return }
        if rStatus == "Accepted" {
            acceptBtn.setTitle("In Progress", for: UIControlState())
            acceptBtn.backgroundColor = UIColor(red: 235.0 / 255.0, green: 135.0 / 255.0, blue: 35.0 / 255.0, alpha: 0.8)
            acceptBtn.isEnabled = false
        }
        else if rStatus == "Completed" {
            acceptBtn.setTitle("Completed", for: UIControlState())
            acceptBtn.backgroundColor = UIColor(red: 35.0 / 255.0, green: 135.0 / 255.0, blue: 235.0 / 255.0, alpha: 0.8)
            acceptBtn.isEnabled = false
        }
        else {
            acceptBtn.setTitle("Accept", for: UIControlState())
        }
        
        if currentUser == addedByUser {
            acceptBtn.isHidden = true

            cancelBtn.isHidden = false
        }
        
        closeModalBtn = UIButton(frame: CGRect(x: 20, y: 28, width: 25.0, height: 25.0))
        closeModalBtn.setImage(UIImage(named: "Close"), for: .normal)
        closeModalBtn.addTarget(self, action: #selector(AcceptRequestViewController.closeModal), for: .touchUpInside)
        
        imagePickerView = UIImagePickerController()
        imageView = UIImageView(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 275.0))
        imageView.image = UIImage(named: "camera")
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(displayCamera)))
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .center
        imageView.layer.cornerRadius = 5.0
        imageView.setNeedsDisplay()
        
        uploadCompletedJobBtn = UIButton(frame: CGRect(x: 10, y: self.view.bounds.height - 70, width: self.view.frame.width - 20, height: 55.0))
        uploadCompletedJobBtn.setTitle("Send Completed Job", for: .normal)
        uploadCompletedJobBtn.backgroundColor = UIColor(red: 35.0 / 255.0, green: 135.0 / 255.0, blue: 235.0 / 255.0, alpha: 0.8)
        uploadCompletedJobBtn.layer.cornerRadius = 5.0
        uploadCompletedJobBtn.isHidden = true
        uploadCompletedJobBtn.addTarget(self, action: #selector(sendCompletedJob), for: .touchUpInside)
        
        instructionsLabel = UILabel(frame: CGRect(x: 10, y: 300, width: self.view.frame.width - 20, height: 50))
        instructionsLabel.numberOfLines = 3
        instructionsLabel.textAlignment = NSTextAlignment.center
        
        instructionsLabel.text = "Once your job is complete, please upload a photo and you'll get paid 💰"
        
        completeRequestView.center.y -= view.bounds.height
        completeRequestView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        view.addSubview(completeRequestView)
        completeRequestView.addSubview(imageView)        
        completeRequestView.addSubview(uploadCompletedJobBtn)
        completeRequestView.addSubview(instructionsLabel)
        completeRequestView.addSubview(closeModalBtn)
        completeRequestView.isHidden = true
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
    
    func deleteRequest() {
        let alert: UIAlertController = UIAlertController(title: "Are you sure?", message: "Are you sure you want to remove your shovel request?", preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            
            guard let requestId = self.id else { return }
            let requestToDelete = self.ref.child(requestId)
            requestToDelete.removeValue()

            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: { _ in })
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
                                            "acceptedByUser": currentUser! as AnyObject]
        
        let childUpdates = ["/\(requestId)": request]
        ref.updateChildValues(childUpdates)
        
        actInd.stopAnimating()
        
        let alert: UIAlertController = UIAlertController(title: "Congrats!", message: "Once the job is complete please take a photo of your work and submit it.", preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let okAction: UIAlertAction = UIAlertAction(title: "Let's Go", style: .default) { (action) in
            self.ref.updateChildValues(childUpdates)
            
            self.showCompleteRequestView()          
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: { _ in })
    }
    
    @IBAction func dismissView(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)        
    }
    
    func closeModal() {
        UIView.animate(withDuration: 3.0, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.0,
                       options: UIViewAnimationOptions.allowUserInteraction, animations: {
                        
                        self.completeRequestView.isHidden = true
        })
    }
    
    func displayCamera() {
        imagePickerView.delegate = self
        
        imagePickerView.sourceType = .camera
        
        present(imagePickerView, animated: true, completion: nil)
    }
    
    func sendCompletedJob() {
        actInd.startAnimating()
        
        guard let requestId = id,
            let address = addressString,
            let description = descriptionString
            else { return }
        let price: Int? = Int(priceString!)
        
        let request: [String: AnyObject] = ["status": "Completed" as AnyObject,
                                            "address": address as AnyObject,
                                            "longitude": longitude!,
                                            "latitude": latitude!,
                                            "details": description as AnyObject,
                                            "addedByUser": addedByUser! as AnyObject,
                                            "otherInfo": "" as AnyObject,
                                            "price": price! as AnyObject,
                                            "id": id! as AnyObject,
                                            "createdAt": createdAt! as AnyObject,
                                            "acceptedByUser": currentUser! as AnyObject]
        
        let childUpdates = ["/\(requestId)": request]
        ref.updateChildValues(childUpdates)
        
        actInd.stopAnimating()
        
        let alert: UIAlertController = UIAlertController(title: "Congrats!", message: "Check to see if there are more requests.", preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.ref.updateChildValues(childUpdates)
            
            // Remove map pin
            
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: { _ in })

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        
        imagePickerView.dismiss(animated: true) { 
            if info.isEmpty {
                print("No photo selected")
                
            }
            else {
                self.imageView.contentMode = UIViewContentMode.scaleAspectFit
                self.imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
                self.uploadCompletedJobBtn.isHidden = false
            }
        }
    }
}
