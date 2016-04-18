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
    var shovelTimeString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    
    func configureView() {
        addressLabel.text = addressString?.uppercaseString
        descriptionLabel.text = descriptionString?.uppercaseString
        priceLabel.text = priceString?.uppercaseString
        if let timeString = shovelTimeString {
            shovelTimeLabel.text = "Average Shovel Time: \(timeString) minutes".uppercaseString
        }
    }
    
    @IBAction func acceptRequest(sender: AnyObject) {
        
    }
    
    @IBAction func dismissView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
}
