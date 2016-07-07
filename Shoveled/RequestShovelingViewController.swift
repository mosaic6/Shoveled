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
class RequestShovelingViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate, PKPaymentAuthorizationViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, STPPaymentContextDelegate {

    // MARK: - Outlets
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfDescription: UITextField!
    @IBOutlet weak var tfShovelTime: UITextField!
    @IBOutlet weak var requestFormView: UIView!
    @IBOutlet weak var dataPicker: UIPickerView!
    @IBOutlet weak var pricePicker: UIPickerView!
    @IBOutlet weak var tfPrice: ShoveledTextField!
    @IBOutlet weak var payWIthCCButton: UIButton!
    @IBOutlet weak var applePayButton: UIButton!
    
    //MARK: - Variables
    let locationManager = CLLocationManager()
    var latitude: Double!
    var longitude: Double!
    var coordinates: CLLocationCoordinate2D!
    var user: User!
    var email: String?
    var items = [ShovelRequest]()
    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()

    var dailyWeather: DailyWeather? {
        didSet {
            configureView()
        }
    }
    
    let shovelDescriptionArray = ["Driveway", "Sidewalk", "Steps", "All of the above"]
    let priceArray = ["10", "15", "20", "25", "30", "35", "40", "45", "50", "55", "60", "65", "70", "75", "80", "85", "90", "95", "100"]
    
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
        
        getUserStatus()
        getLocation()
        configureView()
        
        dataPicker.delegate = self
        pricePicker.delegate = self
        dataPicker.dataSource = self
        pricePicker.dataSource = self
        pricePicker.hidden = true
        
        self.title = "Request"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(RequestShovelingViewController.dismissKeyboards))
        self.view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func dismissKeyboards() {
        tfAddress.resignFirstResponder()
        tfDescription.resignFirstResponder()
        tfPrice.resignFirstResponder()
        tfShovelTime.resignFirstResponder()
        
        dataPicker.hidden = true
        pricePicker.hidden = true
    }
    
    // MARK: - Apple Pay Methods
    
    @IBAction func payWithApplePay(sender: AnyObject) {
        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = "merchant.com.mosaic6.Shoveled"

        paymentRequest.countryCode = "US"
        paymentRequest.currencyCode = "USD"
        
        paymentRequest.supportedNetworks = RequestShovelingViewController.supportedNetworks
        paymentRequest.merchantCapabilities = .Capability3DS
        
        paymentRequest.requiredShippingAddressFields = .Email
        
        var items = [PKPaymentSummaryItem]()
        items.append(PKPaymentSummaryItem(label: "Process Fee", amount: 1.0))
        if let price = tfPrice.text {
            let newPrice = NSDecimalNumber(string: "\(price)")
            let processFee = NSDecimalNumber(double: 1.0)
            let final: NSDecimalNumber = newPrice.decimalNumberByAdding(processFee)
            items.append(PKPaymentSummaryItem(label: "Shoveled", amount: final))
        }
        
        paymentRequest.paymentSummaryItems = items
        
        // Display the view controller.
        let viewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        viewController.delegate = self
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    func configureView() {
        if tfAddress == "" || tfDescription == "" {
            submitButton.enabled = false
        }
        
        tfDescription.becomeFirstResponder()
        
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
    
    // MARK: Textfield delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == tfDescription || textField == tfAddress || textField == tfShovelTime {
            textField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func payWithCreditCard(sender: AnyObject) {
        // If you have your own form for getting credit card information, you can construct
        // your own STPCardParams from number, month, year, and CVV.
//        self.paymentContext.presentPaymentMethodsViewController()
        
    }

    
    @IBAction func closeView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: User status
    func getUserStatus() {
        email = FIRAuth.auth()?.currentUser?.email
        
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
                    guard let shovelTime = self.tfShovelTime.text else { return }
                    guard let price = self.tfPrice.text else { return }
                    let shovelRequest = ShovelRequest(address: address, addedByUser: "", completed: false, accepted: false, latitude: lat, longitude: lon, details: details, shovelTime: shovelTime, price: NSDecimalNumber(string: price))
                    
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
        }
    }

    
    // returns the # of rows in each component..
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if pickerView == dataPicker {
            return 1
        }
        return 1
    }
 
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        if pickerView == dataPicker {
            return shovelDescriptionArray.count
        }
        else {
            return priceArray.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == dataPicker {
            return shovelDescriptionArray[row]
        }
        else {
            return priceArray[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == dataPicker {
            tfDescription.text = shovelDescriptionArray[row]
        }
        else {
            tfPrice.text = priceArray[row]
        }
        self.view.endEditing(true)
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == tfAddress {
            dataPicker.hidden = true
            pricePicker.hidden = true
            return true
        }
        else if textField == tfDescription {
            dataPicker.hidden = false
            pricePicker.hidden = true
            textField.resignFirstResponder()
            tfShovelTime.resignFirstResponder()
            tfAddress.resignFirstResponder()
        }
        else if textField == tfShovelTime {
            dataPicker.hidden = true
            pricePicker.hidden = true
            return true
        }
        else if textField == tfPrice {
            tfShovelTime.resignFirstResponder()
            dataPicker.hidden = true
            pricePicker.hidden = false
            textField.resignFirstResponder()
        }
        return false
    }

}
