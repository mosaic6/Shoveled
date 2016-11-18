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

        
        self.guideDescription()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func guideDescription() {
        let info = "What happens when I send a shovel request?\nOnce your request is out in the wild, one of our shovelers will accept your request, and you'll be notified.\n"
        
        self.guideLabel?.text = info
    }

    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
