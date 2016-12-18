//
//  FAQViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 11/17/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit

class FAQViewController: UIViewController {

    @IBOutlet weak var guideLabel: UILabel?
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.backItem?.title = ""
    }

    @IBAction func contactSupport(_ sender: Any) {
        let email = "support@shoveled.com"
        let url = URL(string: "mailto:\(email)")
        if let url = url {
            UIApplication.shared.openURL(url)
        }
    }

}
