//
//  StripeAccountViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 10/23/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit

class StripeAccountViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var stripeWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.stripeWebView?.delegate = self
        
        guard let url = URL(string: "https://connect.stripe.com/") else { return }
        
        let urlRequest = URLRequest(url: url)
        self.stripeWebView.loadRequest(urlRequest)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.stripeWebView?.loadRequest(NSURLRequest(url: URL(string: "https://connect.stripe.com/login?redirect=%2Foauth%2Fauthorize%3Fresponse_type%3Dcode%26client_id%3Dca_5VEQajzj4GqzKQc6ggbN8XNd0nELUSli%26scope%3Dread_write&force_login=true")!) as URLRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
