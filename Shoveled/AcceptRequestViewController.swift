//
//  AcceptRequestViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 1/16/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit
import Firebase

class AcceptRequestViewController: UIViewController {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var shovelTimeLabel: UILabel!
    
    var addressString: String?
    var descriptionString: String?
    var priceString: String?
    var otherInfoString: String?
//    var accepted: Bool
//    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    
    func configureView() {
        guard let description = descriptionString else { return }
        guard let price = priceString else { return }
        addressLabel.text = addressString?.uppercaseString
        descriptionLabel.text = "Please Shovel: \(description)".uppercaseString
        priceLabel.text = "Price: \(price)".uppercaseString
        if let moreInfoString = otherInfoString {
            shovelTimeLabel.text = "Other Info: \(moreInfoString)".uppercaseString
        }
    }
    
    @IBAction func acceptRequest(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func dismissView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
}
