//
//  HowItWorksViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 10/6/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit

class HowItWorksViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let URL = NSURL(string: "https://www.iubenda.com/privacy-policy/7924006/full-legal")
        let request = NSURLRequest(url: URL as! URL)
        webView.loadRequest(request as URLRequest)
    }

    @IBAction func closeView(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
