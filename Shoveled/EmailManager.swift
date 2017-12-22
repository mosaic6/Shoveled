//
//  EmailManager.swift
//  Shoveled
//
//  Created by Joshua Walsh on 11/20/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation

class EmailManager {

    static var sharedInstance = EmailManager()

    func sendConfirmationEmail(email: String, toName: String, subject: String, text: String, image: String) {
        EmailService.sharedInstance.sendEmailTo(email: email, toName: toName, subject: subject, text: text, image: image)
    }
}
