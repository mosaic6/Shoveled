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
    
    lazy var ref: FIRDatabaseReference = FIRDatabase.database().referenceWithPath("requests")
    let currentUser = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    
    func configureView() {
        
        if currentUser?.email == addedByUser {
            acceptBtn.setTitle("My Request", forState: .Normal)
            acceptBtn.enabled = false
        }
        
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
            acceptBtn.backgroundColor = UIColor(red: 35.0/255.0, green: 35.0/255.0, blue: 35.0/255.0, alpha: 0.8)
            acceptBtn.enabled = false
        }
        else if rStatus == "Completed" {
            acceptBtn.setTitle("Completed", forState: .Normal)
            acceptBtn.backgroundColor = UIColor(red: 35.0/255.0, green: 35.0/255.0, blue: 35.0/255.0, alpha: 0.8)
            acceptBtn.enabled = false
        }
        else {
            acceptBtn.setTitle("Accept", forState: .Normal)
        }
                
    }
    
    func updateRequestDictionaryWith(address: String, latitude: NSNumber, longitude: NSNumber, details: String, addedByUser: String, otherInfo: String, price: NSNumber, status: String, id: String, createdAt: String) {
        
        
    }
    
    @IBAction func acceptRequest(sender: AnyObject) {                
        
        
        
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
                                            "createdAt": createdAt!]
        
        let childUpdates = ["/\(requestId)": request]
        ref.updateChildValues(childUpdates)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func dismissView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)        
    }
}
