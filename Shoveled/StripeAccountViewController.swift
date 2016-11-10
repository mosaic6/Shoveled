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
    var auth_code: String = ""

    @IBOutlet weak var stripeWebView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.stripeWebView?.delegate = self

        let url = URL(string: "https://connect.stripe.com/login?redirect=%2Foauth%2Fauthorize%3Fresponse_type%3Dcode%26client_id%3Dca_5VEQihJDtbmZMAE270MnnY17PY2L8VUJ%26scope%3Dread_write")
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

        // get callback url code
        if let url = webView.request?.url {
            guard let code = url.getQueryItemValueForKey(key: "code") else { return }
            print(code)
            StripeManager.passCodeToAuthAccount(code: code)
        }
    }
}

extension URL {
    func getQueryItemValueForKey(key: String) -> String? {
        guard let components = URLComponents(url: self as URL, resolvingAgainstBaseURL: false) else {
            return nil
        }

        guard let queryItems = components.queryItems else { return nil }
        return queryItems.filter {
            $0.name == key
            }.first?.value
    }
}
