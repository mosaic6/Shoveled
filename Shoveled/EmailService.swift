//
//  EmailService.swift
//  Shoveled
//
//  Created by Joshua Walsh on 10/31/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation

private let API_POST_SENDGRID_EMAIL = "https://api.sendgrid.com/api/mail.send.json"

class EmailService {

    static let sharedInstance = EmailService()

    func sendEmailTo(email: String, toName: String, subject: String, text: String) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        guard var URL = URL(string: API_POST_SENDGRID_EMAIL) else { return }
        let URLParams: [String: String] = [
            "api_user": "mosaic1915",
            "api_key": "pK2VA4ag",
            "to": email,
            "toname": toName,
            "subject": subject,
            "html": text,
            "from": "noreply@shoveled.works"
            ]
        URL = URL.URLByAppendingQueryParameters(URLParams)
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"

        let task = session.dataTask(with: URL, completionHandler: {
            (data, response, error) in
            if (error == nil) {
                // Success

            } else {
                // Failure

            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
}
