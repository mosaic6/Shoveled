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

@available(iOS 9.0, *)
class RequestShovelingViewController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate, PKPaymentAuthorizationViewControllerDelegate, UITextFieldDelegate, STPPaymentContextDelegate {

    // MARK: - Outlets
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfDescription: UITextField!
    @IBOutlet weak var tfShovelTime: UITextField!
    @IBOutlet weak var requestFormView: UIView!
    @IBOutlet weak var tfPrice: ShoveledTextField!
    @IBOutlet weak var payWIthCCButton: UIButton!
    @IBOutlet weak var applePayButton: UIButton!
    
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
    let theme: STPTheme = STPTheme()
//    let paymentContext: STPPaymentContext
    
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
        tfPrice.delegate = self
        addToolBar(tfAddress)
        addToolBar(tfShovelTime)
        addToolBar(tfPrice)
        addToolBar(tfDescription)
        
        applePayButton.userInteractionEnabled = false
        payWIthCCButton.userInteractionEnabled = false
        
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
    
    // MARK: - Apple Pay Methods
    @IBAction func payWithApplePay(sender: AnyObject) {
        startSpinner()
        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = "merchant.com.mosaic6.Shoveled"

        paymentRequest.countryCode = "US"
        paymentRequest.currencyCode = "USD"
        
        paymentRequest.supportedNetworks = RequestShovelingViewController.supportedNetworks
        paymentRequest.merchantCapabilities = .Capability3DS
        
        paymentRequest.requiredShippingAddressFields = .Email
        
        var items = [PKPaymentSummaryItem]()
        if let price = tfPrice.text {
            let newPrice = NSDecimalNumber(string: "\(price)")
            items.append(PKPaymentSummaryItem(label: "Shoveled", amount: newPrice))
        }
        
        paymentRequest.paymentSummaryItems = items
        
        // Display the view controller.
        let viewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        viewController.delegate = self
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    //MARK: Stripe payment delegate
    func paymentContextDidChange(paymentContext: STPPaymentContext) {
        self.payWIthCCButton.enabled = paymentContext.selectedPaymentMethod != nil
    }
    
    func paymentContext(paymentContext: STPPaymentContext,
                        didCreatePaymentResult paymentResult: STPPaymentResult,
                                               completion: STPErrorBlock) {
        
//        myAPIClient.createCharge(paymentResult.source.stripeID, completion: { (error: NSError?) in
//            if let error = error {
//                completion(error)
//            } else {
//                completion(nil)
//            }
//        })
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
    
    @IBAction func payWithCreditCard(sender: AnyObject) {
        // If you have your own form for getting credit card information, you can construct
        // your own STPCardParams from number, month, year, and CVV.

        self.view.backgroundColor = self.theme.primaryBackgroundColor
        var red: CGFloat = 0
        self.theme.primaryBackgroundColor.getRed(&red, green: nil, blue: nil, alpha: nil)
        
    }

    
    @IBAction func closeView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Apple Pay Delegate
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> Void) {
        
        STPAPIClient.sharedClient().createTokenWithPayment(payment) { (token, error) -> Void in
            if error != nil {
                completion(PKPaymentAuthorizationStatus.Failure)
                return
            }
            if let token = token {
                self.createBackendChargeWithToken(token, completion: completion)
            }
        }
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
                    
                    let requestName = self.ref.child("\(postId)")
                    
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
    
    func textFieldDidEndEditing(textField: UITextField) {
        for tf in [textField] {
            if tf.text != "" {
                applePayButton.userInteractionEnabled = true
                payWIthCCButton.userInteractionEnabled = true
            }
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
