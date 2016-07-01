//
//  PaymentDetailsViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 6/27/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit
import Stripe
import FirebaseAuth
import AFNetworking

class PaymentDetailsViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var creditCardBtn: UIButton!
    @IBOutlet weak var applePayBtn: UIButton!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var cardNumberTF: UITextField!
    @IBOutlet weak var experationDateTF: UITextField!
    @IBOutlet weak var cvcTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet var textFields: [UITextField]!
    
    var email: String? = ""
    var cardNumber: String? = ""
    var cvc: String? = ""
    var price: String? = ""
    var visibleRowsPerSection = [[Int]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = false
        self.title = "Payment Details"
        
//        paymentDetails()
        email = FIRAuth.auth()?.currentUser?.email
        emailTF.text = email
        
    }
    
    func paymentDetails() {
        let stripCard = STPCardParams()
//        var validator = STPCardValidator()
        if experationDateTF.text?.isEmpty == false {
            guard let experationDate = experationDateTF.text?.componentsSeparatedByString("/") else { return }
            guard let expMonth = UInt(experationDate[0]) else { return }
            guard let expYear = UInt(experationDate[1]) else { return }
            
            // Send card into to Stripe to get the token
            stripCard.number = cardNumberTF.text
            stripCard.cvc = cvcTF.text
            stripCard.expMonth = expMonth
            stripCard.expYear = expYear
        }
        
        STPAPIClient.sharedClient().createTokenWithCard(stripCard, completion: { (token, error) -> Void in
            
            if error != nil {
                self.handleError(error!)
                return
            }
            
//            self.postStripeToken(token!)
        })
        
    }
    
    func handleError(error: NSError) {
        print(error)
        UIAlertView(title: "Please Try Again",
                    message: error.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
        
    }
    
//    func postStripeToken(token: STPToken) {
//        guard let amount = priceTF.text else { return }
//        let URL = "http://localhost/donate/payment.php"
//        let params = ["stripeToken": token.tokenId,
//                      "amount": Int(amount),
//                      "currency": "usd",
//                      "description": email]
//        
//        let manager = AFHTTPSessionManager()
//        manager.POST(URL, parameters: params, success: { (operation, responseObject) -> Void in
//            
//            if let response = responseObject as? [String: String] {
//                UIAlertView(title: response["status"],
//                    message: response["message"],
//                    delegate: nil,
//                    cancelButtonTitle: "OK").show()
//            }
//            
//        }) { (operation, error) -> Void in
//            self.handleError(error!)
//        }
//    }
    
    @IBAction func chooseCreditCard(sender: AnyObject) {
        
    }
    @IBAction func chooseApplePay(sender: AnyObject) {
        
    }
    
    // MARK: - Text field delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = cardNumberTF.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= 16 // Bool
    }
    
    // MARK: - Tableview sections 
 
}
