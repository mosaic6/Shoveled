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
import SwiftSpinner
import Firebase
import FirebaseDatabase

@objc
protocol CurrentStatusControllerDelegate {
    optional func toggleLeftPanel()
    optional func collapseSidePanels()
}

class CurrentStatusViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate, CLLocationManagerDelegate {

    // MARK: Outlets
    @IBOutlet weak var lblCurrentTemp: UILabel!
    @IBOutlet weak var imgCurrentWeatherIcon: UIImageView!
    @IBOutlet weak var lblCurrentPrecip: UILabel!
    @IBOutlet weak var currentWeatherView: UIView!
    @IBOutlet weak var btnGetShoveled: UIButton!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Variables
    private let forecastAPIKey = "7c0e740db76a3f7f8f03e6115391ea6f"
    let locationManager = CLLocationManager()
    var coordinates: CLLocationCoordinate2D!
    var theirLocation = CLLocationCoordinate2D()
    let dateFormatter = NSDateFormatter()
    var radius = 200.0
    var nearArray : [CLLocationCoordinate2D] = []
    var userLat: Double!
    var userLong: Double!
    var requestStatus: String!
    var delegate: CurrentStatusControllerDelegate?
    lazy var ref: FIRDatabaseReference = FIRDatabase.database().referenceWithPath("requests")
    
    // MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        SwiftSpinner.show("Are those snowflakes?")
        getCurrentLocation()
        configureView()
        getShovelRequests()
        
        let currentUser = FIRAuth.auth()?.currentUser?.email
        print(currentUser)
        
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        getUserInfo()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func configureView() {
        self.navigationController?.navigationBarHidden = true
        self.view.addSubview(currentWeatherView)
    }
    
    func getUserInfo() {
        if FIRAuth.auth()?.currentUser == nil {
            self.performSegueWithIdentifier("notLoggedIn", sender: nil)
        }
    }

    // MARK: - Get users location
    func getCurrentLocation() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            SwiftSpinner.hide()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.coordinates = manager.location?.coordinate
        self.userLat = coordinates.latitude
        self.userLong = coordinates.longitude
        
        let center = CLLocationCoordinate2D(latitude: userLat, longitude: userLong)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.showsUserLocation = true
        self.mapView.userInteractionEnabled = true
        self.mapView.setCenterCoordinate(coordinates, animated: false)
        self.mapView.setRegion(region, animated: false)
        defer { retrieveWeatherForecast() }
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Weather Fetching
    func retrieveWeatherForecast() {
        let forecastService = ForecastService(APIKey: forecastAPIKey)
        forecastService.getForecast(userLat, lon: userLong) {
            (let forecast) in
            
            if let weatherForecast = forecast,
                let currentWeather = weatherForecast.currentWeather {
                dispatch_async(dispatch_get_main_queue()) {
                    if let temp = currentWeather.temperature {
                        self.lblCurrentTemp.text = "\(temp)º"
                    }
                    
                    if let precip = currentWeather.precipProbability {
                        self.lblCurrentPrecip.text = "Precip: \(precip)%"
                    }
                    
                    self.imgCurrentWeatherIcon.image = currentWeather.icon
                    
                }
                SwiftSpinner.hide()
            }
        }
    }
    
    // MARK: - Fetch Request
    func getShovelRequests() {
        ref.observeEventType(.Value, withBlock: { snapshot in
            for item in snapshot.children {
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
                
                self.requestStatus = status
                
                self.theirLocation = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
                self.nearArray.append(self.theirLocation)

                let mapAnnotation = ShovelAnnotation(
                    address: address,
                    coordinate: self.theirLocation,
                    latitude: latitude,
                    longitude: longitude,
                    status: status,
                    price: String(price),
                    details: details,
                    otherInfo: otherInfo,
                    addedByUser: addedByUser,
                    id: id,
                    createdAt: createdAt)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.mapView.addAnnotation(mapAnnotation)
                })
            }            
        }, withCancelBlock: {error in
            print(error.description)
        })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: - Actions
    @IBAction func showMenu(sender: AnyObject) {
        delegate?.toggleLeftPanel?()
    }
    
    // MARK: - Request shoveling
    @IBAction func requestShoveling(sender: AnyObject) {
        self.performSegueWithIdentifier("showRequest", sender: self)
    }
    
}

extension CurrentStatusViewController: SidePanelViewControllerDelegate {
    func cellSelected(cell: MenuItems) {
        
        delegate?.collapseSidePanels?()
    }
}

extension CurrentStatusViewController: MKMapViewDelegate {
    
    //MARK: - MapView Delegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) { return nil }
        
        let identifier = "ShovelAnnotation"
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        if view != nil {
            view?.annotation = annotation
        }
        else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view!.image = UIImage(named: "Snowflaking")
            view!.canShowCallout = true
            view!.calloutOffset = CGPoint(x: -8, y: 0)
            view!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        
        return view
        
    }
    
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let shovel = view.annotation as! ShovelAnnotation
        
        let requestDetailsView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AcceptRequestViewController") as? AcceptRequestViewController
        
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
            
            self.presentViewController(requestVC, animated: true, completion: nil)
        }
    }
}