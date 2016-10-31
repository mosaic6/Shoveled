//
//  StripeAccountViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 10/23/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit

class StripeAccountViewController: UIViewController, UIWebViewDelegate {
    
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var actInd = UIActivityIndicatorView()

    @IBOutlet weak var stripeWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.stripeWebView?.delegate = self
        
        let url = URL(string: "https://connect.stripe.com/login?redirect=%2Foauth%2Fauthorize%3Fresponse_type%3Dcode%26client_id%3Dca_5VEQajzj4GqzKQc6ggbN8XNd0nELUSli%26scope%3Dread_write&force_login=true")
        if let url = url {
            let request = URLRequest(url: url)
            self.stripeWebView?.loadRequest(request)
        }
        
    }
    
    @IBAction func dismissView(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.showActivityIndicatory(self.view)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.hideActivityIndicator(self.view)
    }
}
