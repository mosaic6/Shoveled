//
//  FullScreenViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 12/15/17.
//  Copyright © 2017 Lucky Penguin. All rights reserved.
//

import UIKit

class FullScreenViewController: UIViewController {

    // MARK: Variable

    var message: String?
    var timer: Timer?

    // MARK: Outlets

    @IBOutlet private weak var messageLabel: UILabel?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureMessage()

        self.timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(FullScreenViewController.dismissView), userInfo: nil, repeats: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: .fullScreenDidDisapear, object: nil)
    }

    // MARK: Configure

    func configureMessage() {
        self.messageLabel?.text = self.message ?? ""
    }

    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
        self.timer?.invalidate()
    }
}
