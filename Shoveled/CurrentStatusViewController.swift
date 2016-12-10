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

    // MARK: Variables
    fileprivate let forecastAPIKey = "7c0e740db76a3f7f8f03e6115391ea6f"
    let locationManager = CLLocationManager()
    var coordinates: CLLocationCoordinate2D!
    var theirLocation = CLLocationCoordinate2D()
    let dateFormatter = DateFormatter()
    var radius = 200.0
    var nearArray: [CLLocationCoordinate2D] = []
    var userLat: Double!
    var userLong: Double!
    var requestStatus: String!
    var updateRequestDelegate: UpdateRequestStatusDelegate?
    var ref: FIRDatabaseReference?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ref = FIRDatabase.database().reference(withPath: "requests")

        self.mapView?.delegate = self
        self.configureView()
        self.getShovelRequests()
        self.checkLocationServices()

        NotificationCenter.default.addObserver(self, selector: #selector(AcceptRequestViewController.deleteRequest), name: Notification.Name(rawValue: "cancelRequest"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CurrentStatusViewController.getCurrentLocation), name: Notification.Name(rawValue: userLocationNoticationKey), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.getUserInfo()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getShovelRequests()
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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.coordinates = manager.location?.coordinate
        self.userLat = coordinates.latitude
        self.userLong = coordinates.longitude

        let center = CLLocationCoordinate2D(latitude: userLat, longitude: userLong)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView?.showsUserLocation = true
        self.mapView?.isUserInteractionEnabled = true
        self.mapView?.setCenter(coordinates, animated: false)

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

//        self.showActivityIndicatory(self.view)
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

        let currentUser = FIRAuth.auth()?.currentUser

        let shovel = view.annotation as! ShovelAnnotation

        let requestDetailsView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AcceptRequestViewController") as? AcceptRequestViewController

        if let requestVC = requestDetailsView {
            requestVC.addressString = shovel.title
            requestVC.descriptionString = shovel.details
            requestVC.longitude = shovel.longitude
            requestVC.latitude = shovel.latitude
            requestVC.priceString = shovel.price
            requestVC.addedByUser = shovel.addedByUser
            requestVC.otherInfoString = shovel.otherInfo
            requestVC.status = shovel.status
            requestVC.id = shovel.id
            requestVC.createdAt = shovel.createdAt
            requestVC.acceptedByUser = shovel.acceptedByUser
            requestVC.stripeChargeToken = shovel.stripeChargeToken

            if let user = currentUser?.email, shovel.addedByUser == user {
                 requestVC.titleString = "My Request"
            } else {
                requestVC.titleString = "Accept Your Mission"
            }

            self.present(requestVC, animated: true, completion: nil)
        }
    }
}
