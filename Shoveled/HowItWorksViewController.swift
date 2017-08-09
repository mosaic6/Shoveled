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

        guard let url = URL(string: "https://www.iubenda.com/privacy-policy/7924006/full-legal") else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.loadRequest(request as URLRequest)
    }

    @IBAction func closeView(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
