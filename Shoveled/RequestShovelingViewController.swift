//
//  RequestShovelingViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 11/1/15.
//  Copyright © 2015 Lucky Penguin. All rights reserved.
//

import UIKit
import CoreLocation
import Snowflakes
import SwiftSpinner
import Stripe
import Firebase
import PassKit

@available(iOS 9.0, *)
class RequestShovelingViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, STPPaymentCardTextFieldDelegate, CLLocationManagerDelegate, PKPaymentAuthorizationViewControllerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfDescription: UITextField!
    @IBOutlet weak var tfShovelTime: UITextField!
    @IBOutlet weak var priceControl: UISegmentedControl!
    
    //MARK: - Variables
    let locationManager = CLLocationManager()
    var latitude: Double!
    var longitude: Double!
    var coordinates: CLLocationCoordinate2D!
    var user: User!
    var email: String!
    var items = [ShovelRequest]()
    
    var dailyWeather: DailyWeather? {
        didSet {
            configureView()
        }
    }
    
    static let supportedNetworks = [
        PKPaymentNetworkAmex,
        PKPaymentNetworkDiscover,
        PKPaymentNetworkMasterCard,
        PKPaymentNetworkVisa
    ]
    
    var paymentToken: PKPaymentToken!
    
    // MARK: - Configure Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfAddress.delegate = self
        tfDescription.delegate = self
        tfShovelTime.delegate = self
        getUserStatus()
        getLocation()
        configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(RequestShovelingViewController.supportedNetworks) {
            
            let button = PKPaymentButton(type: .Buy, style: .Black)
            button.addTarget(self, action: #selector(RequestShovelingViewController.applePayButtonPressed), forControlEvents: .TouchUpInside)
            
            button.center = self.view.center
            button.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin]
            self.view.addSubview(button)
        }
    }
    
    // MARK: - Apple Pay Methods
    
    func applePayButtonPressed() {
        // Set up our payment request.
        let paymentRequest = PKPaymentRequest()
        
        /*
         Our merchant identifier needs to match what we previously set up in
         the Capabilities window (or the developer portal).
         */
        paymentRequest.merchantIdentifier = "merchant.com.mosaic6.Shoveled"
        
        /*
         Both country code and currency code are standard ISO formats. Country
         should be the region you will process the payment in. Currency should
         be the currency you would like to charge in.
         */
        paymentRequest.countryCode = "US"
        paymentRequest.currencyCode = "USD"
        
        // The networks we are able to accept.
        paymentRequest.supportedNetworks = RequestShovelingViewController.supportedNetworks
        
        /*
         Ask your payment processor what settings are right for your app. In
         most cases you will want to leave this set to .Capability3DS.
         */
        paymentRequest.merchantCapabilities = .Capability3DS
        
        /*
         An array of `PKPaymentSummaryItems` that we'd like to display on the
         sheet (see the summaryItems function).
         */
        paymentRequest.paymentSummaryItems = makeSummaryItems(requiresInternationalSurcharge: false)
        
        // Request shipping information, in this case just postal address.
        paymentRequest.requiredShippingAddressFields = .PostalAddress
        
        // Display the view controller.
        let viewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        viewController.delegate = self
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    // A function to generate our payment summary items, applying an international surcharge if required.
    func makeSummaryItems(requiresInternationalSurcharge requiresInternationalSurcharge: Bool) -> [PKPaymentSummaryItem] {
        var items = [PKPaymentSummaryItem]()
        
        /*
         Product items have a label (a string) and an amount (NSDecimalNumber).
         NSDecimalNumber is a Cocoa class that can express floating point numbers
         in Base 10, which ensures precision. It can be initialized with a
         double, or in this case, a string.
         */
        if let price = priceControl.titleForSegmentAtIndex(priceControl.selectedSegmentIndex) {
            let shovelSummaryItem = PKPaymentSummaryItem(label: "Sub-total", amount: NSDecimalNumber(string: price))
            items += [shovelSummaryItem]
        }
               
        return items
    }
    
    func configureView() {
        self.view.addSubview(SnowflakesView(frame: self.view.frame))
        
        if tfAddress == "" || tfDescription == "" {
            submitButton.enabled = false
        }
        
        tfDescription.becomeFirstResponder()
        
    }
    
    //MARK: Stripe payment delegate
    func paymentCardTextFieldDidChange(textField: STPPaymentCardTextField) {
        submitButton.enabled = textField.valid
    }
    
    func applePay() {
        let paymentNetworks = [PKPaymentNetworkMasterCard, PKPaymentNetworkVisa]
        
        if PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(paymentNetworks) {
            // create payment request
            let request = PKPaymentRequest()
            
            request.merchantIdentifier = "merchant.com.mosaic6.Shoveled"
            request.countryCode        = "US"
            request.currencyCode       = "USD"
            request.supportedNetworks  = paymentNetworks
            request.merchantCapabilities = .Capability3DS
            
            guard let price = priceControl.titleForSegmentAtIndex(priceControl.selectedSegmentIndex) else { return }
            let total = PKPaymentSummaryItem(label: "Shovel Request", amount: NSDecimalNumber(string: price))
            request.paymentSummaryItems = [total]
            
            let vc = PKPaymentAuthorizationViewController(paymentRequest: request)
            
            vc.delegate = self
            presentViewController(vc, animated: true, completion: nil)
        } else {
            // traditional checkout flow
        }
        
        
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
    
    // MARK: Textfield delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == tfDescription || textField == tfAddress || textField == tfShovelTime {
            textField.resignFirstResponder()
        }
        return false
    }
    
    //MARK: Actions
    @IBAction func sendRequest(sender: AnyObject) {
        
        self.submitButton.enabled = false
        
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
        spinner.setNeedsDisplay()
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        spinner.startAnimating()
        
        let address = tfAddress.text!
        let lat = latitude
        let lon = longitude
        let details = tfDescription.text!
        let shovelTime = tfShovelTime.text!
        guard let price = priceControl.titleForSegmentAtIndex(priceControl.selectedSegmentIndex) else { return }
 
        let shovelRequest = ShovelRequest(address: address, addedByUser: self.email, completed: false, latitude: lat, longitude: lon, details: details, shovelTime: shovelTime, price: price)
        
        let requestName = shovelRef.childByAppendingPath(address.lowercaseString)
        
        requestName.setValue(shovelRequest.toAnyObject()) { (error: NSError?, ref:Firebase!) -> Void in
            if error != nil {
                let alert = UIAlertController(title: "Uh Oh!", message: "There was an error saving your request", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(okAction)
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
//                self.applePay()
            }
        }
    }
    
    @IBAction func closeView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: User status
    func getUserStatus() {
        shovelRef.observeAuthEventWithBlock { authData in
            
            if authData != nil {
                
                self.user = User(authData: authData)
                
                // Create a child reference with a unique id
                let currentUserRef = usersRef.childByAutoId()
                
                // Save the current user to the online users list
                currentUserRef.setValue(self.user.email)
                self.email = self.user.email
                
                // When the user disconnects remove the value
                currentUserRef.onDisconnectRemoveValue()
            }
            
        }
        
        // Create a value observer
//        usersRef.observeEventType(.Value, withBlock: { (snapshot: FDataSnapshot!) in
//            
//            // Check to see if the snapshot has any data
//            if snapshot.exists() {
//                // do something
//            } else {
//                
//            }
//        })
    }
    
    
    //MARK: Apple Pay Delegate
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> Void) {
        paymentToken = payment.token
        
        completion(.Success)
        
//        performSegueWithIdentifier(<#T##identifier: String##String#>, sender: <#T##AnyObject?#>)
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        
    }
}
