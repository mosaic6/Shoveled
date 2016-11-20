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
    var latitude: NSNumber!
    var longitude: NSNumber!
    var coordinates: CLLocationCoordinate2D!
    var user: User!
    var items = [ShovelRequest]()
    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    weak var toolBar: UIToolbar!
    var paymentTextField: STPPaymentCardTextField? = nil
    var sendToStripeBtn: UIButton! = nil
    var priceLabel: UILabel! = nil
    var feeLabel: UILabel!
    var paymentToken: PKPaymentToken!

    // MARK: - Private Variables
    private var shovelRequest: ShovelRequest?

    static let SupportedNetworks = [
        PKPaymentNetwork.amex,
        PKPaymentNetwork.discover,
        PKPaymentNetwork.masterCard,
        PKPaymentNetwork.visa
    ]

    // MARK: - Configure Views
    override func viewDidLoad() {
        super.viewDidLoad()
        StripeManager.getCustomers() { (result) in

        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(RequestShovelingViewController.dismissKeyboards))
        self.view.addGestureRecognizer(tap)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.configureAppearance()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tfDescription.becomeFirstResponder()
        getLocation()
    }

    func configureAppearance() {
        self.tfAddress.delegate = self
        self.tfDescription.delegate = self
        self.tfShovelTime.delegate = self
        self.tfPrice.delegate = self
        self.addToolBar(tfAddress)
        self.addToolBar(tfShovelTime)
        self.addToolBar(tfPrice)
        self.addToolBar(tfDescription)

        self.payWIthCCButton.setTitle("Submit & Pay", for: UIControlState())

        actInd.frame = CGRect(x: 25, y: 25, width: 50, height: 50)
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        actInd.isHidden = true
        view.addSubview(actInd)

        self.title = "Request"

    }

    func getUserEmail() -> String {
        guard let email = FIRAuth.auth()?.currentUser?.email else { return "" }
        return email
    }

    func dismissKeyboards() {
        self.tfAddress.resignFirstResponder()
        self.tfDescription.resignFirstResponder()
        self.tfPrice.resignFirstResponder()
        self.tfShovelTime.resignFirstResponder()
    }

    //MARK: - Location Manager Delegate
    func getLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        self.coordinates = manager.location?.coordinate
        self.latitude = coordinates.latitude as NSNumber
        self.longitude = coordinates.longitude as NSNumber

        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error) -> Void in
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

    func displayLocationInfo(_ placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            let thoroughfare: String! = (containsPlacemark.thoroughfare != nil) ? containsPlacemark.thoroughfare : ""
            let subthoroughfare: String! = (containsPlacemark.subThoroughfare != nil) ? containsPlacemark.subThoroughfare : ""
            let locality: String! = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let postalCode: String! = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            let administrativeArea: String! = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            let address = "\(subthoroughfare!) \(thoroughfare!), \(locality!), \(administrativeArea!) \(postalCode!)"
            tfAddress.text = address
        }
    }

    //MARK: Stripe payment delegate
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        self.sendToStripeBtn.isEnabled = textField.valid
        self.sendToStripeBtn.isEnabled = false
        sendToStripeBtn.backgroundColor = UIColor(red: 78.0 / 255.0, green: 68.0 / 255.0, blue: 77.0 / 255.0, alpha: 0.5)
        if textField.valid {
            self.sendToStripeBtn.backgroundColor = UIColor(red: 78.0 / 255.0, green: 168.0 / 255.0, blue: 177.0 / 255.0, alpha: 1)
            self.sendToStripeBtn.isEnabled = true
        }
    }

    @IBAction func submitCard(_ sender: AnyObject?) {

        DispatchQueue.main.async {
            self.paymentTextField?.resignFirstResponder()
        }

        showActivityIndicatory(self.view)
        guard let card = paymentTextField?.cardParams else { return }

        STPAPIClient.shared().createToken(withCard: card) { token, error in
            guard let stripeToken = token else {
                NSLog("Error creating token: %@", error!.localizedDescription)
                return
            }

            if !stripeToken.tokenId.isEmpty {
                guard let amount = self.tfPrice.text else { return }
                let price: Int = Int(amount)! * 100 + 75
                let stringPrice = String(price)

                StripeManager.sendChargeToStripeWith(amount: stringPrice, source: String(stripeToken.tokenId), description: "Shoveled Requests From \(self.getUserEmail())", completion: { (chargeId) in
                    self.addRequestOnSuccess(stripeToken: chargeId)
                })
                self.resignFirstResponder()
                
                self.hideActivityIndicator(self.view)
            }
        }
    }

    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        self.sendToStripeBtn.isEnabled = paymentContext.selectedPaymentMethod != nil
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWithStatus status: STPPaymentStatus, error: NSError?) {
        switch status {
        case .error:
            print("\(error?.localizedDescription)")
        case .success:
            self.dismiss(animated: true, completion: nil)
            self.removeFromParentViewController()
        case .userCancellation:
            return // do nothing
        }
    }

    @IBAction func payWithCreditCard(_ sender: AnyObject) {
        sendToStripeBtn = UIButton(type: .system)
        sendToStripeBtn.setTitle("Pay Now", for: UIControlState())
        sendToStripeBtn.titleLabel?.font = UIFont(name: "Rajdhani", size: 30)
        sendToStripeBtn.setTitleColor(UIColor.white, for: UIControlState())
        sendToStripeBtn.addTarget(self, action: #selector(self.submitCard(_: )), for: UIControlEvents.touchUpInside)
        sendToStripeBtn.frame = CGRect(x: 0, y: (self.view.frame.height / 2) + 60, width: view.frame.width, height: 55)
        sendToStripeBtn.isEnabled = false
        priceLabel = UILabel(frame: CGRect(x: 0, y: 125, width: view.frame.width, height: 80))
        priceLabel.font = UIFont(name: "Marvel-Bold", size: 50.0)
        priceLabel.textAlignment = .center
        guard let price = tfPrice.text else { return }
        priceLabel.text = "💲\(price).00"

        feeLabel = UILabel(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 40))
        feeLabel.font = UIFont(name: "Marvel-Regular", size: 18)
        feeLabel.textAlignment = .center
        feeLabel.text = "$0.75 processing fee will be applied"

        paymentTextField = STPPaymentCardTextField(frame: CGRect(x: 15, y: (self.view.frame.height / 2) - 50, width: view.frame.width - 30, height: 44))
        paymentTextField?.delegate = self

        if tfAddress.text == "" || tfDescription.text == "" || tfPrice.text == "" {
            let alert = UIAlertController(title: "Eh!", message: "Looks like you missed something", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Try again!", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: false, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.requestFormView.alpha = 0
                self.payWIthCCButton.isHidden = true
                self.view.layoutIfNeeded()
            }, completion: nil)

            UIView.animate(withDuration: 0.3, delay: 0.4, options: UIViewAnimationOptions(), animations: {
                self.view.addSubview(self.sendToStripeBtn)
                if let paymentTextField = self.paymentTextField {
                    self.view.addSubview(paymentTextField)
                }
                self.view.addSubview(self.priceLabel)
                self.view.addSubview(self.feeLabel)
                self.paymentTextField?.becomeFirstResponder()
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    @IBAction func closeView(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func addRequestOnSuccess(stripeToken: String) {
        let postId = Int(arc4random_uniform(10000) + 1)
        guard let address = self.tfAddress.text else { return }
        guard let lat = self.latitude else { return }
        guard let lon = self.longitude else { return }
        guard let details = self.tfDescription.text else { return }
        guard let otherInfo = self.tfShovelTime.text else { return }
        guard let price = self.tfPrice.text else { return }
        guard let email = FIRAuth.auth()?.currentUser?.email else { return }
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
        let dateString = dateFormatter.string(from: date)

        self.shovelRequest = ShovelRequest(address: address, addedByUser: email, status: "Active", latitude: lat, longitude: lon, details: details, otherInfo: otherInfo, price: NSDecimalNumber(string: price), id: String(postId), createdAt: dateString, acceptedByUser: "", stripeChargeToken: stripeToken)
        
        let alert = UIAlertController(title: "Congrats!", message: "Your request at \(address), to have your \(details) shoveled, for $\(price) has been sent.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { alert in
            let requestName = self.ref.child("/requests/\(postId)")
            
            requestName.setValue(self.shovelRequest?.toAnyObject(), withCompletionBlock: { (error, ref) in
                if error != nil {
                    let alert = UIAlertController(title: "Uh Oh!", message: "There was an error saving your request", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    Crashlytics.sharedInstance().recordError(error!)
                }
            })
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    func addToolBar(_ textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76 / 255, green: 217 / 255, blue: 100 / 255, alpha: 1)

        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(RequestShovelingViewController.done))

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()

        textField.inputAccessoryView = toolBar
    }

    func done() {
        self.view.endEditing(true)
    }
}
