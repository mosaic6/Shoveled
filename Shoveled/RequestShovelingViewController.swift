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

class RequestShovelingViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, STPPaymentCardTextFieldDelegate, CLLocationManagerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfDescription: UITextField!
    @IBOutlet weak var tfShovelTime: UITextField!
    //MARK: - Variables
    let locationManager = CLLocationManager()
    var paymentTextField: STPPaymentCardTextField! = nil
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
        
    // MARK: - Configure Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfAddress.delegate = self
        tfDescription.delegate = self
        tfShovelTime.delegate = self
        getUserStatus()
        getLocation()
        paymentInfo()
        configureView()
        
        
    }
    
    func paymentInfo() {
        paymentTextField = STPPaymentCardTextField(frame: CGRectMake(15, 280, CGRectGetWidth(view.frame) - 30, 44))
        paymentTextField.delegate = self
//        view.addSubview(paymentTextField)
//
//        submitButton.setTitle("Submit", forState: UIControlState.Normal)
//        submitButton.addTarget(self, action: "submitCard:", forControlEvents: UIControlEvents.TouchUpInside)
//        view.addSubview(submitButton)
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
//        submitButton.enabled = textField.valid
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
            
            // TODO: send the token to your server so it can create a charge
            let alert = UIAlertController(title: "Welcome to Stripe", message: "Token created: \(stripeToken)", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
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
        
        let shovelRequest = ShovelRequest(address: address, addedByUser: self.email, completed: false, latitude: lat, longitude: lon, details: details, shovelTime: shovelTime)
        let requestName = shovelRef.childByAppendingPath(address.lowercaseString)
        
        requestName.setValue(shovelRequest.toAnyObject()) { (error: NSError?, ref:Firebase!) -> Void in
            if error != nil {
                let alert = UIAlertController(title: "Uh Oh!", message: "There was an error saving your request", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(okAction)
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
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
}
