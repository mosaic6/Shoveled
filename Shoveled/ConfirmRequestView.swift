//
//  ConfirmRequestView.swift
//  Shoveled
//
//  Created by Joshua Walsh on 11/12/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation
import UIKit

protocol ConfirmRequestDelegate: class {
    func dismissConfirmRequestView()
}

class ConfirmRequestView: UIView {

    @IBOutlet private weak var confirmButton: ShoveledButton?
    @IBOutlet private weak var addressLabel: UILabel?
    @IBOutlet private weak var descriptionLabel: UILabel?
    @IBOutlet private weak var otherInfoLabel: UILabel?
    @IBOutlet private weak var priceLabel: UILabel?
    @IBOutlet private weak var containerView: UIView?
    @IBOutlet private weak var detailsView: UIView?

    private weak var delegate: ConfirmRequestDelegate?

    class func create(viewController: UIViewController, request: ShovelRequest) -> ConfirmRequestView {
        let views = Bundle.main.loadNibNamed("ConfirmRequestView", owner: self, options: nil) ?? []
        let confirmView = views[0] as! ConfirmRequestView
        confirmView.configureView(viewController: viewController, request: request)
        confirmView.delegate = viewController as? ConfirmRequestDelegate
        return confirmView

    }

    func configureView(viewController: UIViewController, request: ShovelRequest) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: viewController.view.frame.size.height)
        viewController.view.addSubview(self)

        let address = request.address
        let descriptionInfo = request.details
        let otherInfo = request.otherInfo
        let price = request.price.stringValue

        self.addressLabel?.text = address
        self.descriptionLabel?.text = descriptionInfo
        self.otherInfoLabel?.text = otherInfo
        self.priceLabel?.text = price

        self.containerView?.layer.cornerRadius = 5.0
        self.detailsView?.layer.cornerRadius = 5.0

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    @IBAction func confirmRequest(_ sender: Any) {
        self.delegate?.dismissConfirmRequestView()
    }
}
