//
//  EmailService.swift
//  Shoveled
//
//  Created by Joshua Walsh on 10/31/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation
import SendGrid

private let API_POST_SENDGRID_EMAIL = "https://api.sendgrid.com/api/mail.send.json"

class EmailService {

    static let sharedInstance = EmailService()

    func sendEmailTo(email: String, toName: String, subject: String, text: String, image: String) {
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
            "files": image,
            "filename": "Completed Shovel Job",
            "from": "noreply@shoveled.works"
            ]
        URL = URL.URLByAppendingQueryParameters(URLParams)
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"

        let task = session.dataTask(with: URL, completionHandler: {
            (_, _, error) in
            if (error == nil) {
                print("sent email successfully")
            } else {
                print("failed to send email")

            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
}
