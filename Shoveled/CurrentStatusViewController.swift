//
//  CurrentStatusViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 9/21/15.
//  Copyright © 2015 Lucky Penguin. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
import FirebaseDatabase

protocol UpdateRequestStatusDelegate {
    func getShovelRequests()
}

protocol LocationServicesDelegate {
    func checkLocationServices()
}

let completedOrCancelledNotification = "com.mosaic6.removePinNotification"

class CurrentStatusViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate, CLLocationManagerDelegate, UpdateRequestStatusDelegate {

    // MARK: Outlets
    @IBOutlet weak var lblCurrentTemp: UILabel?
    @IBOutlet weak var imgCurrentWeatherIcon: UIImageView?
    @IBOutlet weak var lblCurrentPrecip: UILabel?
    @IBOutlet weak var currentWeatherView: UIView?
    @IBOutlet weak var btnGetShoveled: UIButton?
    @IBOutlet weak var mapContainerView: UIView?
    @IBOutlet weak var bottomView: UIView?
    @IBOutlet weak var mapView: MKMapView?
    @IBOutlet weak var refreshMapBtn: UIButton?
    @IBOutlet weak var shovelerImageView: UIImageView?
    @IBOutlet weak var numOfShovelersLabel: ShoveledButton?
    // MARK: Variables
    fileprivate let forecastAPIKey = "7c0e740db76a3f7f8f03e6115391ea6f"
    fileprivate let locationManager = CLLocationManager()
    fileprivate var coordinates: CLLocationCoordinate2D!
    fileprivate var theirLocation = CLLocationCoordinate2D()
    fileprivate let dateFormatter = DateFormatter()
    fileprivate var radius = 200.0
    fileprivate var nearArray: [CLLocationCoordinate2D] = []
    fileprivate var userLat: Double!
    fileprivate var userLong: Double!
    fileprivate var requestStatus: String!
    fileprivate var updateRequestDelegate: UpdateRequestStatusDelegate?
    fileprivate var locationDelegate: LocationServicesDelegate?
    fileprivate var ref: FIRDatabaseReference?
    fileprivate var postalCode: String?
    fileprivate var numOfShovelers = 0
    var isUserShoveler = false

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        StripeManager.getStripeAccountBalance { (amount) in
            print(amount)
        }
        self.ref = FIRDatabase.database().reference(withPath: "requests")
        self.shovelerImageView?.isHidden = true
        self.mapView?.delegate = self
        self.configureView()
        self.checkLocationServices()

        NotificationCenter.default.addObserver(self, selector: #selector(RequestDetailsViewController.deleteRequest), name: Notification.Name(rawValue: "cancelRequest"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CurrentStatusViewController.getCurrentLocation), name: Notification.Name(rawValue: userLocationNoticationKey), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getUserInfo()
        self.areShovelersAvailable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.areShovelersAvailable()
        self.isUserAShoveler()
        self.getShovelRequests()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.numOfShovelers = 0
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                print("no access")
            case .authorizedAlways, .authorizedWhenInUse:
                self.getCurrentLocation()
            }
        }
    }

    func configureView() {
        self.navigationController?.isNavigationBarHidden = true
        if let currentWeatherView = self.currentWeatherView {
            self.view.addSubview(currentWeatherView)
        }
    }

    func getUserInfo() {
        if FIRAuth.auth()?.currentUser == nil {
            self.performSegue(withIdentifier: "notLoggedIn", sender: nil)
        }
    }

    // MARK: - Get users location
    func getCurrentLocation() {
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func displayLocationInfo(_ placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            locationManager.stopUpdatingLocation()
            self.postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""            
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.coordinates = manager.location?.coordinate
        self.userLat = coordinates.latitude
        self.userLong = coordinates.longitude

        let center = CLLocationCoordinate2D(latitude: userLat, longitude: userLong)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView?.showsUserLocation = true
        self.mapView?.isUserInteractionEnabled = true
        self.mapView?.setCenter(coordinates, animated: false)
        
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

        self.mapView?.setRegion(region, animated: false)
        defer { retrieveWeatherForecast() }
        locationManager.stopUpdatingLocation()
    }

    // MARK: - Weather Fetching
    func retrieveWeatherForecast() {
        let forecastService = ForecastService(APIKey: forecastAPIKey)
        forecastService.getForecast(userLat, lon: userLong) {
            (forecast) in

            if let weatherForecast = forecast,
                let currentWeather = weatherForecast.currentWeather {
                DispatchQueue.main.async {
                    if let temp = currentWeather.temperature {
                        self.lblCurrentTemp?.text = "\(temp)º"
                    }

                    if let precip = currentWeather.precipProbability {
                        self.lblCurrentPrecip?.text = "Precip: \(precip)%"
                    }

                    self.imgCurrentWeatherIcon?.image = currentWeather.icon

                }
            }
        }
    }

    // MARK: - Fetch Request
    func getShovelRequests() {
        self.removeAnnotations()

        self.showActivityIndicatory(self.view)
        self.ref?.observe(.value, with: { snapshot in
            if let items = snapshot.value as? [String: AnyObject] {
                for item in items {
                    guard let address = item.value["address"] as? String else { return }
                    guard let addedByUser = item.value["addedByUser"] as? String else { return }
                    guard let status = item.value["status"] as? String else { return }
                    guard let latitude = item.value["latitude"] as? NSNumber else { return }
                    guard let longitude = item.value["longitude"] as? NSNumber else { return }
                    guard let details = item.value["details"] as? String else { return }
                    guard let otherInfo = item.value["otherInfo"] as? String else { return }
                    guard let price = item.value["price"] as? NSNumber else { return }
                    guard let id = item.value["id"] as? String else { return }
                    guard let createdAt = item.value["createdAt"] as? String else { return }
                    guard let acceptedByUser = item.value["acceptedByUser"] as? String else { return }
                    guard let stripeChargeToken = item.value["stripeChargeToken"] as? String else { return }

                    self.requestStatus = status

                    self.theirLocation = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
                    self.nearArray.append(self.theirLocation)

                    let mapAnnotation = ShovelAnnotation(
                        address: address,
                        coordinate: self.theirLocation,
                        latitude: latitude,
                        longitude: longitude,
                        status: status,
                        price: String(describing: price),
                        details: details,
                        otherInfo: otherInfo,
                        addedByUser: addedByUser,
                        id: id,
                        createdAt: createdAt,
                        acceptedByUser: acceptedByUser,
                        stripeChargeToken: stripeChargeToken)

                    DispatchQueue.main.async {
                        self.mapView?.addAnnotation(mapAnnotation)
                        if status == "Completed" {
                            self.mapView?.removeAnnotation(mapAnnotation)
                        }
                        self.hideActivityIndicator(self.view)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.hideActivityIndicator(self.view)
                }

            }
        })
    }

    // Make this a delegate method that gets called when completing a request or canceling one
    func removeAnnotations() {
        guard let allAnnotations = self.mapView?.annotations else { return }
        self.mapView?.removeAnnotations(allAnnotations)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    // MARK: - Request shoveling
    @IBAction func requestShoveling(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "showRequest", sender: self)
    }

    @IBAction func refreshMap(_ sender: AnyObject) {

        self.getCurrentLocation()

        UIView.animate(withDuration: 0.3) {
            self.refreshMapBtn?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        }
        UIView.animate(withDuration: 0.3, delay: 0.25, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.refreshMapBtn?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI * 2))
            }, completion: nil)
        getShovelRequests()
    }

}

extension CurrentStatusViewController: MKMapViewDelegate {

    //MARK: - MapView Delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if (annotation is MKUserLocation) { return nil }

        let identifier = "ShovelAnnotation"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if view != nil {
            view?.annotation = annotation
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view!.image = UIImage(named: "mapPin")
            view!.canShowCallout = true
            view!.calloutOffset = CGPoint(x: 0, y: 0)
            view!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }

        return view
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let shovel = view.annotation as! ShovelAnnotation
        let vc = storyboard?.instantiateViewController(withIdentifier: "RequestDetailsViewController") as? RequestDetailsViewController
        let nav: UINavigationController = UINavigationController(rootViewController: vc!)
        if let requestVC = vc {
            requestVC.addressString = shovel.title
            requestVC.descriptionString = shovel.details
            requestVC.longitude = shovel.longitude
            requestVC.latitude = shovel.latitude
            requestVC.priceString = shovel.price
            requestVC.addedByUser = shovel.addedByUser
            requestVC.moreInfoString = shovel.otherInfo
            requestVC.status = shovel.status
            requestVC.id = shovel.id
            requestVC.createdAt = shovel.createdAt
            requestVC.acceptedByUser = shovel.acceptedByUser
            requestVC.stripeChargeToken = shovel.stripeChargeToken
            requestVC.isShoveler = self.isUserShoveler

            self.present(nav, animated: true, completion: nil)
        }
    }
}

extension CurrentStatusViewController {
    
    fileprivate func isUserAShoveler() {
        if currentUserUid != "" {
            shovelerRef?.child("users").child(currentUserUid).observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                let shoveler = value?["shoveler"] as? NSDictionary ?? [:]
                if let stripeId = shoveler.object(forKey: "stripeId") as? String, stripeId != "" {
                    self.shovelerImageView?.isHidden = false
                    self.isUserShoveler = true
                } else {
                    self.shovelerImageView?.isHidden = true
                    self.isUserShoveler = false
                }
            }) { error in
                print(error.localizedDescription)
            }
        } else {
            self.getUserInfo()
        }
    }
}

extension CurrentStatusViewController {
    
    fileprivate func areShovelersAvailable() {
        shovelerRef?.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let users = snapshot.value
                guard let user = users as? NSDictionary else { return }
                for data in user  {
                    let shovelers = data.value
                    guard let data = shovelers as? NSDictionary else { return }
                    if let shoveler = data["shoveler"] as? NSDictionary {
                        if let postalCode = shoveler["postalCode"] as? String, postalCode == self.postalCode {
                            self.numOfShovelers += 1
                            let shovelerCount = "\(self.numOfShovelers)"
                            switch self.numOfShovelers {
                            case 0:
                                self.numOfShovelersLabel?.setTitle("No shovelers in area", for: .normal)
                            case 1:
                                self.numOfShovelersLabel?.setTitle("\(shovelerCount) shoveler in area", for: .normal)
                            case 2...100000:
                                self.numOfShovelersLabel?.setTitle("\(shovelerCount) shovelers in area", for: .normal)
                            default: break
                            }
                        }
                    } else {
                        self.numOfShovelersLabel?.setTitle("No shovelers in area", for: .normal)
                    }
                }
            }
        })
    }
}
