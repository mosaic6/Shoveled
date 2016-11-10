//
//  CompletedJobService.swift
//  Shoveled
//
//  Created by Joshua Walsh on 11/2/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

class CompletedJobService {

    static let sharedInstance = CompletedJobService()

    let currentUser = FIRAuth.auth()?.currentUser?.email

    func getCompletedJobImage(fromId: String) {
        let imageRef = FIRStorage.storage().reference().child(fromId)
        imageRef.downloadURL { (url, error) in
            if (error != nil) {
                    // Handle any errors
            } else {
                if let url = url {
                    do {
                        let downloadUrl = try String(contentsOf: url)
                        EmailService.sharedInstance.sendEmailTo(email: self.currentUser!, toName: "", subject: "Your Request Is Complete!", text: "", file: downloadUrl)
                    } catch {
                        print("error")
                    }
                }
            }
        }
    }
}
