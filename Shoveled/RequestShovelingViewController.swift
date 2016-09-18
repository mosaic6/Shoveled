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
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    static let supportedNetworks = [
        PKPaymentNetworkAmex,
        PKPaymentNetworkDiscover,
        PKPaymentNetworkMasterCard,
        PKPaymentNetworkVisa
    ]
    
    // MARK: - Configure Views
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureAppearance()
        getUserEmail()
        
        StripeManager.getCustomers() { (result) in
            
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(RequestShovelingViewController.dismissKeyboards))
        self.view.addGestureRecognizer(tap)        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getLocation()
    }
    
    func configureAppearance() {
        tfAddress.delegate = self
        tfDescription.delegate = self
        tfShovelTime.delegate = self
        tfPrice.delegate = self
        addToolBar(tfAddress)
        addToolBar(tfShovelTime)
        addToolBar(tfPrice)
        addToolBar(tfDescription)
        
        payWIthCCButton.setTitle("Submit & Pay", forState: UIControlState.Normal)
        
        actInd.frame = CGRectMake(25, 25, 50, 50)
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        actInd.hidden = true
        view.addSubview(actInd)
        
        self.title = "Request"

    }
    
    func getUserEmail() -> String {
        guard let email = FIRAuth.auth()?.currentUser?.email else { return "" }
        
        return email
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
        
        dispatch_async(dispatch_get_main_queue()) { 
            self.paymentTextField.resignFirstResponder()
        }        
        
        showActivityIndicatory(self.view)
        
        let card = paymentTextField.cardParams
        
        STPAPIClient.sharedClient().createTokenWithCard(card) { token, error in
            guard let stripeToken = token else {
                NSLog("Error creating token: %@", error!.localizedDescription);
                return
            }
            
            if !stripeToken.tokenId.isEmpty {
                guard let amount = self.tfPrice.text else { return }
                let price:Int = Int(amount)! * 100
                
//                StripeManager.createCustomerStripeAccountWith("New Shoveled Customer", source: String(stripeToken.tokenId), email: self.getUserEmail(), completion: { (success, error) in
//                    
//                })
//                
                StripeManager.sendChargeToStripeWith(String(price), source: String(stripeToken.tokenId), description: "Shoveled Requests From \(self.getUserEmail())", completion: { (success, error) in
                    
                })
                
                self.addRequestOnSuccess()
                // display success message and send email with confirmation
                
                self.dismissViewControllerAnimated(true, completion: nil)
                self.hideActivityIndicator(self.view)
            
            }
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
        sendToStripeBtn.titleLabel?.font = UIFont(name: "Rajdhani", size: 30)
        sendToStripeBtn.backgroundColor = UIColor(red: 78.0/255.0, green: 168.0/255.0, blue: 177.0/255.0, alpha: 1)
        sendToStripeBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        sendToStripeBtn.addTarget(self, action: #selector(self.submitCard(_ :)), forControlEvents: UIControlEvents.TouchUpInside)
        sendToStripeBtn.frame = CGRectMake(0, (self.view.frame.height / 2) + 60, CGRectGetWidth(view.frame), 55)
        priceLabel = UILabel(frame: CGRectMake(0, 125, CGRectGetWidth(view.frame), 80))
        priceLabel.font = UIFont(name: "Marvel-Bold", size: 50.0)
        priceLabel.textAlignment = NSTextAlignment.Center
        guard let price = tfPrice.text else { return }
        priceLabel.text = "💲\(price).00"
        
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
    
    func addRequestOnSuccess() {
        let postId = Int(arc4random_uniform(10000) + 1)
        guard let address = self.tfAddress.text else { return }
        guard let lat = self.latitude else { return }
        guard let lon = self.longitude else { return }
        guard let details = self.tfDescription.text else { return }
        guard let otherInfo = self.tfShovelTime.text else { return }
        guard let price = self.tfPrice.text else { return }
        guard let email = FIRAuth.auth()?.currentUser?.email else { return }
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
        let dateString = dateFormatter.stringFromDate(date)
        let shovelRequest = ShovelRequest(address: address, addedByUser: email, status: "Active", latitude: lat, longitude: lon, details: details, otherInfo: otherInfo, price: NSDecimalNumber(string: price), id: String(postId), createdAt: dateString)
        
        let requestName = self.ref.child("/requests/\(postId)")
        
        requestName.setValue(shovelRequest.toAnyObject(), withCompletionBlock: { (error, ref) in
            if error != nil {
                let alert = UIAlertController(title: "Uh Oh!", message: "There was an error saving your request", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(okAction)
                self.presentViewController(alert, animated: true, completion: nil)
                Crashlytics.sharedInstance().recordError(error!)
            }
        })
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
    
    func showActivityIndicatory(uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 0.5)
        
        loadingView.frame = CGRectMake(0, 0, 80, 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor(red: 68.0/255.0, green: 68.0/255.0, blue: 68.0/255.0, alpha: 0.8)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.WhiteLarge
        actInd.center = CGPointMake(loadingView.frame.size.width / 2,
                                    loadingView.frame.size.height / 2);
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        actInd.startAnimating()
    }
    
    func hideActivityIndicator(uiView: UIView) {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }
}
