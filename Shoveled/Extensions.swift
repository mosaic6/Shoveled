//
//  Extensions.swift
//  Taasky
//
//  Created by Audrey M Tam on 18/03/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit
import Foundation

var container: UIView = UIView()
var loadingView: UIView = UIView()
var actInd = UIActivityIndicatorView()

extension UIColor {
  convenience init(colorArray array: NSArray) {
    let r = array[0] as! CGFloat
    let g = array[1] as! CGFloat
    let b = array[2] as! CGFloat
    self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
  }
}

extension UIViewController {
    func showSpinner(_ style: UIActivityIndicatorViewStyle) {
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50)) as UIActivityIndicatorView
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = style
        view.addSubview(actInd)
        actInd.startAnimating()
    }

    func hideSpinner() {
        actInd.isHidden = true
    }
}

extension UIViewController {
    func showActivityIndicatory(_ uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColor(red: 155.0 / 255.0, green: 155.0 / 255.0, blue: 155.0 / 255.0, alpha: 0.5)

        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor(red: 68.0 / 255.0, green: 68.0 / 255.0, blue: 68.0 / 255.0, alpha: 0.8)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10

        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        actInd.center = CGPoint(x: loadingView.frame.size.width / 2,
                                    y: loadingView.frame.size.height / 2)
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        actInd.startAnimating()
    }

    func hideActivityIndicator(_ uiView: UIView) {
        actInd.stopAnimating()
        container.removeFromSuperview()
    }
}

extension UIViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTage = textField.tag + 1
        // Try to find next responder
        let nextResponder = textField.superview?.viewWithTag(nextTage) as UIResponder!

        if (nextResponder != nil) {
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }

        return false // We do not want UITextField to insert line-breaks.
    }
}
