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
class RequestShovelingViewController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    fileprivate enum CellIdentifier: String {
        case address1Cell = "address1Cell"
        case shovelingDescriptionCell = "shovelingDescriptionCell"
        case moreInfoCell = "moreInfoCell"
        case priceCell = "priceCell"
        case whatToChargeCell = "whatToChargeCell"
        case paymentInfoCell = "paymentInfoCell"
    }

    fileprivate var tableViewData: [[CellIdentifier]] = []
    fileprivate var address1Cell: RequestCell?
    fileprivate var shovelingDescriptionCell: RequestCell?
    fileprivate var moreInfoCell: RequestCell?
    fileprivate var priceCell: RequestCell?
    fileprivate var whatToChargeCell: RequestCell?
    fileprivate var paymentInfoCell: RequestCell?
    fileprivate var postalCode: String?

    fileprivate var address1: String? {
        get {
            return self.address1Cell?.tfAddress?.text
        }
        set {
            self.address1Cell?.tfAddress?.text = newValue
        }
    }

    fileprivate var shovelingDescription: String? {
        return self.shovelingDescriptionCell?.tfDescription?.text
    }

    fileprivate var moreInfo: String? {
        return self.moreInfoCell?.tfMoreInfo?.text
    }

    fileprivate var price: String? {
        return self.priceCell?.tfPrice?.text
    }

    fileprivate var paymentInfoTF: STPPaymentCardTextField? {
        return self.paymentInfoCell?.tfCardDetails
    }

    //MARK: - Variables

    let locationManager = CLLocationManager()
    var latitude: NSNumber!
    var longitude: NSNumber!
    var coordinates: CLLocationCoordinate2D!
    var user: User!
    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    var chargeId: String?

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint?
    @IBOutlet weak var submitRequestButton: UIBarButtonItem?

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
        
        self.address1Cell?.tfAddress?.delegate = self
        self.address1Cell?.tfPrice?.delegate = self
        self.shovelingDescriptionCell?.tfDescription?.delegate = self
        self.moreInfoCell?.tfMoreInfo?.delegate = self
        self.priceCell?.tfPrice?.delegate = self

        self.getLocation()
        self.rebuildTableViewDataAndRefresh()

        NotificationCenter.default.addObserver(self, selector: #selector(RequestShovelingViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configureAppearance()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    func configureAppearance() {

        actInd.frame = CGRect(x: 25, y: 25, width: 50, height: 50)
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        actInd.isHidden = true
        view.addSubview(actInd)

        self.title = "REQUEST"

    }

    fileprivate func rebuildTableViewDataAndRefresh() {
        let tableViewData: [[CellIdentifier]]

        tableViewData = self.tableViewDataForRequest()

        self.tableViewData = tableViewData
        self.tableView?.tableFooterView = UIView()
        self.tableView?.reloadData()
    }

    fileprivate func tableViewDataForRequest() -> [[CellIdentifier]] {
        var tableViewData: [[CellIdentifier]] = []
        var requestData: [CellIdentifier] = []

        requestData.append(.address1Cell)
        requestData.append(.shovelingDescriptionCell)
        requestData.append(.moreInfoCell)
        requestData.append(.priceCell)
        requestData.append(.whatToChargeCell)
        requestData.append(.paymentInfoCell)

        tableViewData.append(requestData)

        return tableViewData
    }

    //MARK: - Location Manager Delegate
    func getLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Hmmm", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
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
    
    func getCoordinatesFromAddress(address: String) -> CLPlacemark? {
        let geocoder = CLGeocoder()
        var placemark = CLPlacemark()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemarks = placemarks {
                if placemarks.count != 0 {
                    placemark = placemarks[0]
                }
            }
        }
        return placemark
    }

    func displayLocationInfo(_ placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            locationManager.stopUpdatingLocation()
            let thoroughfare: String? = (containsPlacemark.thoroughfare != nil) ? containsPlacemark.thoroughfare : ""
            let subthoroughfare: String? = (containsPlacemark.subThoroughfare != nil) ? containsPlacemark.subThoroughfare : ""
            let locality: String? = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            self.postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            let administrativeArea: String? = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            let address = "\(subthoroughfare!) \(thoroughfare!), \(locality!), \(administrativeArea!) \(postalCode!)"
            self.address1 = address
        }
    }

    func submitCard() {
        guard let paymentInfo = self.paymentInfoTF else { return }
        if self.address1 == "" || self.shovelingDescription == "" || self.price == "" || !paymentInfo.hasText {
            let alert = UIAlertController(title: "Eh!", message: "Looks like you missed something", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Try again!", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: false, completion: nil)
        } else {
            showActivityIndicatory(self.view)
            guard let card = self.paymentInfoTF?.cardParams else { return }

            STPAPIClient.shared().createToken(withCard: card) { token, error in
                guard let stripeToken = token else {
                    return
                }

                if !stripeToken.tokenId.isEmpty {
                    guard let amount = self.price else { return }
                    let price: Int = Int(amount)! * 100
                    let stringPrice = String(price)

                    let tokenId = stripeToken.tokenId

                    StripeManager.sendChargeToStripeWith(amount: stringPrice, source: tokenId, description: "Shoveled Requests From \(currentUserEmail)", completion: { chargeId in
                        if !chargeId.isEmpty {
                            self.addRequestOnSuccess(stripeToken: chargeId)
                            self.chargeId = chargeId
                            self.sendConfirmationEmail(email: currentUserEmail, subject: "Your Shovel request has been sent!", text: "<html><div>Great news, your request is ready to be accepted. Hold tight and we'll get you shoveled out in no time.\nFor you reference, your payment ID is <b>\(chargeId)</b>.<br/>If you should have any issues canceling your request, please use this ID as a reference and email support.</div></html>")
                            self.hideActivityIndicator(self.view)
                        } else {
                            let alert = UIAlertController(title: "Something went wrong", message: "We could not complete your request. Please check that your card information is correct.", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Try again", style: .default) { alert in
                                self.hideActivityIndicator(self.view)
                            }
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                    DispatchQueue.main.async {
                        self.paymentInfoTF?.resignFirstResponder()
                    }
                }
            }
        }
    }

    @IBAction func submitRequest(_ sender: Any) {
        self.submitCard()
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWithStatus status: STPPaymentStatus, error: NSError?) {
        switch status {
        case .error:
            print("\(error?.localizedDescription)")
        case .success:
            self.dismiss(animated: true, completion: nil)
            self.removeFromParentViewController()
        case .userCancellation:
            return
        }
    }

    @IBAction func closeView(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func addRequestOnSuccess(stripeToken: String) {
        guard let address = self.address1 else { return }
        guard let lat = self.latitude else { return }
        guard let lon = self.longitude else { return }
        guard let details = self.shovelingDescription else { return }
        guard let otherInfo = self.moreInfo else { return }

        guard let price = self.price else { return }
        let newPrice: Int = Int(price)! * 100
        let stringPrice = String(newPrice)
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
        let dateString = dateFormatter.string(from: date)

        self.shovelRequest = ShovelRequest(address: address, addedByUser: currentUserEmail, status: "Active", latitude: Double(lat), longitude: Double(lon), details: details, otherInfo: otherInfo, price: Float(NSDecimalNumber(string: stringPrice)), createdAt: dateString, acceptedByUser: "", stripeChargeToken: stripeToken)

        let alert = UIAlertController(title: "Congrats!", message: "Your request at \(address), to have your \(details) shoveled, for $\(price) has been sent.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { alert in
            let requestName = self.ref.child("/requests/").childByAutoId()
            self.hideActivityIndicator(self.view)
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
}

extension RequestShovelingViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewData[section].count
    }

    fileprivate func indexPathForCellIdentifier(_ identifier: CellIdentifier) -> IndexPath? {
        for (sectionIndex, sectionData) in self.tableViewData.enumerated() {
            for (rowIndex, cellIdentifier) in sectionData.enumerated() {
                if cellIdentifier == identifier {
                    return IndexPath(row: rowIndex, section: sectionIndex)
                }
            }
        }

        return nil
    }

    fileprivate func identifier(at indexPath: IndexPath) -> CellIdentifier? {
        return self.tableViewData[indexPath.section][indexPath.row]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellIdentifier = self.identifier(at: indexPath) else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.rawValue)!

        switch cellIdentifier {
        case .address1Cell:
            let address1Cell = cell as! RequestCell
            self.address1Cell = address1Cell
        case .shovelingDescriptionCell:
            let descriptionCell = cell as! RequestCell
            descriptionCell.tfDescription?.becomeFirstResponder()
            self.shovelingDescriptionCell = descriptionCell
        case .moreInfoCell:
            let moreInfoCell = cell as! RequestCell
            self.moreInfoCell = moreInfoCell
        case .priceCell:
            let priceCell = cell as! RequestCell
            self.priceCell = priceCell
        case .whatToChargeCell:
            let whatToChargeCell = cell as! RequestCell
            self.whatToChargeCell = whatToChargeCell
        case .paymentInfoCell:
            let paymentInfoCell = cell as! RequestCell
            self.paymentInfoCell = paymentInfoCell
        }

        return cell
    }
}

// MARK: TableView delegate
extension RequestShovelingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellIdentifier = self.identifier(at: indexPath) else {
            return 44.0
        }

        switch cellIdentifier {
        case .address1Cell, .shovelingDescriptionCell, .moreInfoCell, .priceCell, .whatToChargeCell:
            return 44.0
        case .paymentInfoCell:
            return 65.0
        }
    }
}

// MARK: Keyboard delegate
extension RequestShovelingViewController {

    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.tableView?.frame.origin.y == 0 {
                self.tableViewBottomConstraint?.constant = keyboardSize.size.height
                self.tableViewBottomConstraint?.isActive = true
            }
        }
    }
}

// MARK: Email delegate
extension RequestShovelingViewController {

    fileprivate func sendConfirmationEmail(email: String, subject: String, text: String) {
        EmailService.sharedInstance.sendEmailTo(email: email, toName: "", subject: subject, text: text)
    }
}

// MARK: TextField delegate
extension RequestShovelingViewController {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.address1Cell?.tfAddress {
            if let address = self.address1Cell?.tfAddress {
                if let addressText = address.text {
                    let placemark = self.getCoordinatesFromAddress(address: addressText)
                    print(placemark?.addressDictionary as Any)
                }
            }
        }
    }
}

