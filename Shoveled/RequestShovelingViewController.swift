//
//  RequestShovelingViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 11/1/15.
//  Copyright © 2015 Lucky Penguin. All rights reserved.
//

import UIKit
import CoreLocation
import Stripe
import Firebase
import PassKit
import Crashlytics
import FutureKit

@available(iOS 9.0, *)
class RequestShovelingViewController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate, UITextFieldDelegate, STPPaymentCardTextFieldDelegate {

    // MARK: - Outlets
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfDescription: UITextField!
    @IBOutlet weak var tfShovelTime: UITextField!
    @IBOutlet weak var requestFormView: UIView!
    @IBOutlet weak var tfPrice: ShoveledTextField!
    @IBOutlet weak var payWIthCCButton: UIButton!
    
    //MARK: - Variables
    let locationManager = CLLocationManager()
    var latitude: Double!
    var longitude: Double!
    var coordinates: CLLocationCoordinate2D!
    var user: User!
    var items = [ShovelRequest]()
    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    weak var toolBar: UIToolbar!
    var actInd = UIActivityIndicatorView()
    var paymentTextField: STPPaymentCardTextField! = nil
    var sendToStripeBtn: UIButton! = nil
    var priceLabel: UILabel! = nil
    var paymentToken: PKPaymentToken!
    
    static let supportedNetworks = [
        PKPaymentNetworkAmex,
        PKPaymentNetworkDiscover,
        PKPaymentNetworkMasterCard,
        PKPaymentNetworkVisa
    ]
    
    // MARK: - Configure Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfAddress.delegate = self
        tfDescription.delegate = self
        tfShovelTime.delegate = self
        tfPrice.delegate = self
        addToolBar(tfAddress)
        addToolBar(tfShovelTime)
        addToolBar(tfPrice)
        addToolBar(tfDescription)
        
        payWIthCCButton.setTitle("Submit & Pay", forState: UIControlState.Normal)
        
        actInd.frame = CGRectMake(0,0, 50, 50)
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        actInd.hidden = true
        view.addSubview(actInd)
        
        self.title = "Request"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(RequestShovelingViewController.dismissKeyboards))
        self.view.addGestureRecognizer(tap)        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getLocation()
    }
    
    func dismissKeyboards() {
        tfAddress.resignFirstResponder()
        tfDescription.resignFirstResponder()
        tfPrice.resignFirstResponder()
        tfShovelTime.resignFirstResponder()
    }
    
    //MARK: - Location Manager Delegate
    
    func getLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.coordinates = manager.location?.coordinate
        self.latitude = coordinates.latitude
        self.longitude = coordinates.longitude
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)-> Void in
            if (error != nil) {
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                self.displayLocationInfo(pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func displayLocationInfo(placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            let thoroughfare: String! = (containsPlacemark.thoroughfare != nil) ? containsPlacemark.thoroughfare : ""
            let subthoroughfare: String! = (containsPlacemark.subThoroughfare != nil) ? containsPlacemark.subThoroughfare : ""
            let locality: String! = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let postalCode: String! = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            let administrativeArea: String! = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            let address = "\(subthoroughfare) \(thoroughfare), \(locality), \(administrativeArea) \(postalCode)"
            tfAddress.text = address
        }
    }
    
    //MARK: Stripe payment delegate
    func paymentCardTextFieldDidChange(textField: STPPaymentCardTextField) {
        payWIthCCButton.enabled = textField.valid
    }
    
    @IBAction func submitCard(sender: AnyObject?) {
        // If you have your own form for getting credit card information, you can construct
        // your own STPCardParams from number, month, year, and CVV.
        let card = paymentTextField.cardParams
        
        STPAPIClient.sharedClient().createTokenWithCard(card) { token, error in
            guard let stripeToken = token else {
                NSLog("Error creating token: %@", error!.localizedDescription);
                return
            }
            self.createBackendChargeWithToken(stripeToken, completion: { (status: PKPaymentAuthorizationStatus) in
                if status == .Success {
                    guard let amount = self.tfPrice.text else { return }
                    let price:Int = Int(amount)! * 100
                    StripeManager.sharedInstance.sendChargeToStripeWith(String(price), source: String(stripeToken.tokenId), description: "Shoveled Requested")
                    
                    // display success message and send email with confirmation
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        }
    }
    
    func paymentContextDidChange(paymentContext: STPPaymentContext) {
        self.sendToStripeBtn.enabled = paymentContext.selectedPaymentMethod != nil
    }
    
    func paymentContext(paymentContext: STPPaymentContext, didFinishWithStatus status: STPPaymentStatus, error: NSError?) {
        switch status {
        case .Error:
            print("\(error?.localizedDescription)")
        case .Success:
            self.dismissViewControllerAnimated(true, completion: nil)
            self.removeFromParentViewController()
        case .UserCancellation:
            return // do nothing
        }
    }
    func paymentContext(paymentContext: STPPaymentContext, didFailToLoadWithError error: NSError) {
        self.navigationController?.popViewControllerAnimated(true)
        // show the error to your user, etc
    }
    
    @IBAction func payWithCreditCard(sender: AnyObject) {

        sendToStripeBtn = UIButton(type: .System)
        sendToStripeBtn.setTitle("Pay Now", forState: .Normal)
        sendToStripeBtn.backgroundColor = UIColor(red: 78.0/255.0, green: 168.0/255.0, blue: 177.0/255.0, alpha: 1)
        sendToStripeBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        sendToStripeBtn.addTarget(self, action: #selector(self.submitCard(_ :)), forControlEvents: UIControlEvents.TouchUpInside)
        sendToStripeBtn.frame = CGRectMake(0, (self.view.frame.height / 2) + 60, CGRectGetWidth(view.frame), 55)
        priceLabel = UILabel(frame: CGRectMake(0, 125, CGRectGetWidth(view.frame), 80))
        priceLabel.font = UIFont(name: "Marvel-Bold", size: 50.0)
        priceLabel.textAlignment = NSTextAlignment.Center
        guard let price = tfPrice.text else { return }
        priceLabel.text = "$\(price)"
        
        paymentTextField = STPPaymentCardTextField(frame: CGRectMake(15, (self.view.frame.height / 2) - 50, CGRectGetWidth(view.frame) - 30, 44))
        paymentTextField.delegate = self
        
        if tfAddress.text == "" || tfDescription.text == "" || tfPrice.text == "" {
            let alert = UIAlertController(title: "Eh!", message: "Looks like you missed something", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Try again!", style: .Default, handler: nil)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: false, completion: nil)
        }
        else {
            UIView.animateWithDuration(0.3, delay: 0.0, options: [.CurveEaseInOut], animations: {
                self.requestFormView.alpha = 0
                self.payWIthCCButton.hidden = true
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            UIView.animateWithDuration(0.3, delay: 0.4, options: [.CurveEaseInOut], animations: {
                self.view.addSubview(self.sendToStripeBtn)
                self.view.addSubview(self.paymentTextField)
                self.view.addSubview(self.priceLabel)
                self.paymentTextField.becomeFirstResponder()
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
 
    }

    
    @IBAction func closeView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func createBackendChargeWithToken(token: STPToken, completion: PKPaymentAuthorizationStatus -> ()) {
        let url = NSURL(string: "https://api.stripe.com/v1/tokens")
        if let url = url {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let body = "stripeToken=(token.tokenId)"
            request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
            request.addValue("Bearer \(AppConfiguration.authKey)", forHTTPHeaderField: "Authorization")
            let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
            let session = NSURLSession(configuration: configuration)
            let task = session.dataTaskWithRequest(request) {  (data, response, error) -> Void in
                if error != nil {
                    completion(PKPaymentAuthorizationStatus.Failure)
                }
                else {
                    if let data = data {
                        if let json: AnyObject = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) {
                            if let dict = json as? NSDictionary {
                                print(dict)
                            }
                        }
                    }
                    let postId = Int(arc4random_uniform(10000) + 1)
                    guard let address = self.tfAddress.text else { return }
                    guard let lat = self.latitude else { return }
                    guard let lon = self.longitude else { return }
                    guard let details = self.tfDescription.text else { return }
                    guard let otherInfo = self.tfShovelTime.text else { return }
                    guard let price = self.tfPrice.text else { return }
                    guard let email = FIRAuth.auth()?.currentUser?.email else { return }
                    let shovelRequest = ShovelRequest(address: address, addedByUser: email, completed: false, accepted: false, latitude: lat, longitude: lon, details: details, otherInfo: otherInfo, price: NSDecimalNumber(string: price))
                    
                    let requestName = self.ref.child("/requests\(postId)")
                    
                    requestName.setValue(shovelRequest.toAnyObject(), withCompletionBlock: { (error, ref) in                                                                
                        if error != nil {
                            let alert = UIAlertController(title: "Uh Oh!", message: "There was an error saving your request", preferredStyle: .Alert)
                            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            alert.addAction(okAction)
                            self.presentViewController(alert, animated: true, completion: nil)                            
                            Crashlytics.sharedInstance().recordError(error!)
                        }
                    })
                    completion(PKPaymentAuthorizationStatus.Success)
                }
            }
            task.resume()
            stopSpinner()
        }
    }
    
    func addToolBar(textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(RequestShovelingViewController.done))
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.inputAccessoryView = toolBar
    }
    
    func done() {
        self.view.endEditing(true)
    }
    
    func startSpinner() {
        actInd.hidden = false
        actInd.startAnimating()
    }
    
    func stopSpinner() {
        actInd.hidden = true
        actInd.stopAnimating()
    }
    
}
