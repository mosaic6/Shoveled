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

class CurrentStatusViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate, CLLocationManagerDelegate, UpdateRequestStatusDelegate {

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
    fileprivate var ref = Database.database().reference(withPath: "requests")
    fileprivate var hasBeenShown: Bool = false
    var shoveler: Shoveler?

    var requests = [ShovelRequest]()

    fileprivate var postalCode: String?
    fileprivate var numOfShovelers = 0
    var isUserShoveler = false

    // MARK: Outlets

    @IBOutlet weak var lblCurrentTemp: UILabel?
    @IBOutlet weak var imgCurrentWeatherIcon: UIImageView?
    @IBOutlet weak var lblCurrentPrecip: UILabel?
    @IBOutlet weak var btnGetShoveled: UIButton?
    @IBOutlet weak var mapContainerView: UIView?
    @IBOutlet weak var bottomView: UIView?
    @IBOutlet weak var mapView: MKMapView?
    @IBOutlet weak var refreshMapBtn: UIButton?
    @IBOutlet weak var numOfShovelersLabel: ShoveledButton?
    @IBOutlet weak var requestsListBtn: ShoveledButton?
    @IBOutlet weak var settingsButton: UIBarButtonItem?
    @IBOutlet weak var weatherView: UIView?

    // MARK: - Request shoveling
    @IBAction func requestShoveling(_ sender: AnyObject) {
        if self.numOfShovelersLabel?.titleLabel?.text?.contains("0") ?? false {
            let alert: UIAlertController = UIAlertController(title: "Shucks", message: "It doesn't look like there are any shovelers in your area yet.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "RequestShovelingViewController") as? RequestShovelingViewController
            if let vc = vc {
                let nav: UINavigationController = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: nil)
            }
        }
    }

    @IBAction func refreshMap(_ sender: AnyObject) {
        self.getCurrentLocation()
        self.areShovelersAvailable()

        UIView.animate(withDuration: 0.3) {
            self.refreshMapBtn?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        }
        UIView.animate(withDuration: 0.3, delay: 0.25, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.refreshMapBtn?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
        }, completion: nil)
        getShovelRequests()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = false
        self.mapView?.delegate = self
        self.checkLocationServices()
        self.registerNotificationServices()
        self.requestsListBtn?.addTarget(self, action: #selector(CurrentStatusViewController.showRequestsListViewController), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configureRequestButton()
        self.configureWeatherView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.areShovelersAvailable()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getUserInfo()
        self.getShovelRequests()
        self.isUserAShoveler()
        self.navigationController?.navigationBar.barTintColor = UIColor.lightGray
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.numOfShovelers = 0
    }

    func registerNotificationServices() {
        NotificationCenter.default.addObserver(self, selector: #selector(RequestDetailsViewController.deleteRequest), name: Notification.Name(rawValue: "cancelRequest"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CurrentStatusViewController.getCurrentLocation), name: Notification.Name(rawValue: userLocationNoticationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CurrentStatusViewController.applicationEnteredBackground), name: .UIApplicationDidEnterBackground, object: nil)
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

    func getUserInfo() {
        if Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "notLoggedIn", sender: nil)
        }
    }

    // MARK: - UI Configuration

    func configureRequestButton() {
        let btnHeight = self.btnGetShoveled?.frame.size.height ?? 0
        self.btnGetShoveled?.layer.cornerRadius = btnHeight / 2
    }

    private func configureWeatherView() {
        guard let weatherView = self.weatherView else {
            return
        }
        let rectShape = CAShapeLayer()

        rectShape.bounds = weatherView.frame
        rectShape.position = weatherView.center
        rectShape.path = UIBezierPath(roundedRect: weatherView.bounds, byRoundingCorners: [.bottomRight], cornerRadii: CGSize(width: 50, height: 50)).cgPath

        weatherView.layer.backgroundColor = UIColor.white.cgColor
        weatherView.layer.mask = rectShape
    }

    // MARK: - Get users location

    @objc func getCurrentLocation() {
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
                self.areShovelersAvailable()
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

        self.ref.observe(.value, with: { snapshot in
            var requests: [ShovelRequest] = []
            for item in snapshot.children {
                let request = ShovelRequest(snapshot: item as? DataSnapshot)
                requests.append(request)

                self.theirLocation = CLLocationCoordinate2D(latitude: request.latitude, longitude: request.longitude)
                let mapAnnotation = ShovelAnnotation(coordinate: self.theirLocation, title: request.address, shovelRequest: request)

                DispatchQueue.main.async {
                    self.mapView?.addAnnotation(mapAnnotation)

                    if request.status == "Completed" {
                        self.mapView?.removeAnnotation(mapAnnotation)
                    }
                }
            }
            self.requests = requests
            DispatchQueue.main.async {
                if !self.hasBeenShown {
                    self.animateInCurrentWeatherView()
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
}

extension CurrentStatusViewController: MKMapViewDelegate {

    // MARK: - MapView Delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }

        let identifier = "ShovelAnnotation"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if view != nil {
            view?.annotation = annotation
            view?.canShowCallout = true
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
            requestVC.shovelRequest = shovel.shovelRequest
            requestVC.isShoveler = self.isUserShoveler
            self.present(nav, animated: true, completion: nil)
        }
    }
}

// MARK: Shoveler info
extension CurrentStatusViewController {

    fileprivate func isUserAShoveler() {
        if currentUserUid != "" {
            shovelerRef.child("users").child(currentUserUid).observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                let shoveler = value?["shoveler"] as? NSDictionary ?? [:]
                if let stripeId = shoveler.object(forKey: "stripeId") as? String, stripeId != "" {
                    self.isUserShoveler = true
                } else {
                    self.isUserShoveler = false
                }
            }) { error in
                let alert: UIAlertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                self.present(alert, animated: true)
            }
        } else {
            self.getUserInfo()
        }
    }

    private func enableShovelerActivity() {
        let requestName = self.ref.child("users").child(currentUserUid).child("shoveler")
        requestName.setValue(self.shoveler?.toAnyObject()) { error, _ in
            if error == nil {

            }
        }
    }
}

// MARK: Get number of shovelers
extension CurrentStatusViewController {

    fileprivate func areShovelersAvailable() {
        self.numOfShovelers = 0
        self.numOfShovelersLabel?.setTitle("0 ☃️", for: .normal)
        shovelerRef.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let users = snapshot.value
                guard let user = users as? Dictionary<String, Any> else { return }
                for data in user {
                    let shovelers = data.value
                    if let data = shovelers as? Dictionary<String, Any> {
                        if let shoveler = data["shoveler"] as? Dictionary<String, Any> {
                            if let postalCode = shoveler["postalCode"] as? String, postalCode == self.postalCode {
                                self.numOfShovelers += 1
                                let shovelerCount = "\(self.numOfShovelers)"
                                DispatchQueue.main.async {
                                    switch self.numOfShovelers {
                                    case 0:
                                        self.numOfShovelersLabel?.setTitle("No shovelers in area", for: .normal)
                                    case 1...100000:
                                        self.numOfShovelersLabel?.setTitle("\(shovelerCount) ☃️", for: .normal)
                                    default: break
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
}

// MARK: Show Requests List View Controller
extension CurrentStatusViewController {

    @objc fileprivate func showRequestsListViewController() {
        let storyboard = UIStoryboard(name: "RequestsListStoryboard", bundle: nil)
        guard let requestsListTableViewController = storyboard.instantiateViewController(withIdentifier: "RequestsListTableViewController") as? RequestsListTableViewController else {
            return
        }
        let navController: UINavigationController = UINavigationController(rootViewController: requestsListTableViewController)

        self.present(navController, animated: true, completion: nil)
    }
}

// MARK: Animations

extension CurrentStatusViewController {

    func animateInCurrentWeatherView() {
        self.imgCurrentWeatherIcon?.center.y -= self.view.bounds.height
        UIView.animate(withDuration: 1.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.hasBeenShown = true
        })
        UIView.animate(withDuration: 2, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.imgCurrentWeatherIcon?.center.y += self.view.bounds.height
        }, completion: nil)
    }
}

extension CurrentStatusViewController {

    @objc func applicationEnteredBackground(_ notification: Notification) {
        self.hasBeenShown = false
    }
}
