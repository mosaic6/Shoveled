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

class AcceptRequestViewController: UIViewController {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var shovelTimeLabel: UILabel!
    @IBOutlet weak var acceptBtn: ShoveledButton!
    @IBOutlet weak var cancelBtn: UIButton!
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
    lazy var ref: FIRDatabaseReference = FIRDatabase.database().referenceWithPath("requests")
    let currentUser = FIRAuth.auth()?.currentUser?.email
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(AcceptRequestViewController.showCompleteRequestView))
//        self.view.addGestureRecognizer(tap)
    }

    
    func configureView() {
        
        cancelBtn.hidden = true
        
        guard let description = descriptionString else { return }
        guard let price = priceString else { return }
        
        addressLabel.text = addressString?.uppercaseString
        descriptionLabel.text = "Please Shovel: \(description)".uppercaseString
        priceLabel.text = "Will Pay: $\(price).00".uppercaseString
        if let moreInfoString = otherInfoString where moreInfoString == "" {
            shovelTimeLabel.text = "No more details for you!".uppercaseString
        }
        else {
            shovelTimeLabel.text = "Other Info: \(otherInfoString)".uppercaseString
        }
        
        guard let rStatus = status else { return }
        if rStatus == "Accepted" {
            acceptBtn.setTitle("In Progress", forState: .Normal)
            acceptBtn.backgroundColor = UIColor(red: 235.0/255.0, green: 135.0/255.0, blue: 35.0/255.0, alpha: 0.8)
            acceptBtn.enabled = false
        }
        else if rStatus == "Completed" {
            acceptBtn.setTitle("Completed", forState: .Normal)
            acceptBtn.backgroundColor = UIColor(red: 35.0/255.0, green: 135.0/255.0, blue: 235.0/255.0, alpha: 0.8)
            acceptBtn.enabled = false
        }
        else {
            acceptBtn.setTitle("Accept", forState: .Normal)
        }
        
        if currentUser == addedByUser {
            acceptBtn.hidden = true

            cancelBtn.hidden = false
        }
        
        self.completeRequestView.center.y -= view.bounds.height
        self.completeRequestView.frame = CGRectMake(10, 20, self.view.frame.size.width - 20, self.view.frame.size.height - 30)
        view.addSubview(self.completeRequestView)
        self.completeRequestView.hidden = true
    }
    
    func showCompleteRequestView() {
        self.completeRequestView.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 5.0,
                                   options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                        
            self.completeRequestView.hidden = false
            self.completeRequestView.center.y += 0
            self.completeRequestView.transform = CGAffineTransformIdentity
        }, completion: nil)
    }

    @IBAction func cancelRequest(sender: AnyObject) {
        deleteRequest()
    }
    func deleteRequest() {
        let alert: UIAlertController = UIAlertController(title: "Are you sure?", message: "Are you sure you want to remove your shovel request?", preferredStyle: .Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .Destructive, handler: nil)
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { (action) in
            
            guard let requestId = self.id else { return }
            let requestToDelete = self.ref.child(requestId)
            requestToDelete.removeValue()

            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: { _ in })
    }
    
    @IBAction func acceptRequest(sender: AnyObject) {                
        
        actInd.startAnimating()
        
        guard let requestId = id,
            address = addressString,
            description = descriptionString
            else { return }
        let price: Int? = Int(priceString!)
        
        let request: [String: AnyObject] = ["status": "Accepted",
                                            "address": address,
                                            "longitude": longitude!,
                                            "latitude": latitude!,
                                            "details": description,
                                            "addedByUser": addedByUser!,
                                            "otherInfo": "",
                                            "price": price!,
                                            "id": id!,
                                            "createdAt": createdAt!,
                                            "acceptedByUser": currentUser!]
        
        let childUpdates = ["/\(requestId)": request]
        ref.updateChildValues(childUpdates)
        
        actInd.stopAnimating()
        
        let alert: UIAlertController = UIAlertController(title: "Congrats!", message: "Once the job is complete please take a photo of your work and submit it.", preferredStyle: .Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Destructive, handler: nil)
        let okAction: UIAlertAction = UIAlertAction(title: "Let's Go", style: .Default) { (action) in
            self.ref.updateChildValues(childUpdates)
            
            self.showCompleteRequestView()          
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: { _ in })
    }
    
    @IBAction func dismissView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)        
    }
}
