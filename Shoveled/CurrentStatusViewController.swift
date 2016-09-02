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
    var items = [ShovelRequest]()
    var delegate: CurrentStatusControllerDelegate?
    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    
    // MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        SwiftSpinner.show("Are those snowflakes?")
        getCurrentLocation()
        filterByProximity()
        configureView()
        
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        getUserInfo()
        getShovelRequests()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        filterByProximity()
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
    
    
    // MARK: - Get Shovel Requests
    func filterByProximity() {
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in

            var newRequest = [ShovelRequest]()
            for _ in snapshot.children {
                let shovelItem = ShovelRequest()
                newRequest.append(shovelItem)
                let theirLat: Double = shovelItem.latitude.doubleValue
                let theirLong: Double = shovelItem.longitude.doubleValue
                self.theirLocation = CLLocationCoordinate2D(latitude: theirLat, longitude: theirLong)
                self.nearArray.append(self.theirLocation)
                if self.nearArray.isEmpty {
                    let annotationsToRemove = self.mapView.annotations.filter { $0 !== self.mapView.userLocation } as? MKAnnotation
                    self.mapView.removeAnnotation(annotationsToRemove!)
                } else {
                    for _ in self.nearArray {
                        let mapAnnotation = ShovelAnnotation(address: shovelItem.address, coordinate: self.theirLocation, completed: false, accepted: false, price: String(shovelItem.price), details: shovelItem.details, otherInfo: shovelItem.otherInfo)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.mapView.addAnnotation(mapAnnotation)
                        })
                    }
                }
            }
        })
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
//        var request = ShovelRequest()
        ref.observeEventType(.Value, withBlock: { snapshot in
            for item in snapshot.children {
                guard let address = item.value["address"] as? String else { return }
                guard let addedByUser = item.value["addedByUser"] as? String else { return }
                guard let completed = item.value["completed"] as? Bool else { return }
                guard let accepted = item.value["accepted"] as? Bool else { return }
                guard let latitude = item.value["latitude"] as? NSNumber else { return }
                guard let longitude = item.value["longitude"] as? NSNumber else { return }
                guard let details = item.value["details"] as? String else { return }
                guard let otherInfo = item.value["otherInfo"] as? String else { return }
                guard let price = item.value["price"] as? NSNumber else { return }
                
                self.theirLocation = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
                self.nearArray.append(self.theirLocation)
                if self.nearArray.isEmpty {
                    let annotationsToRemove = self.mapView.annotations.filter { $0 !== self.mapView.userLocation } as? MKAnnotation
                    self.mapView.removeAnnotation(annotationsToRemove!)
                } else {
                    for _ in self.nearArray {
                        let mapAnnotation = ShovelAnnotation(address: address, coordinate: self.theirLocation, completed: completed, accepted: accepted, price: String(price), details: details, otherInfo: otherInfo)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.mapView.addAnnotation(mapAnnotation)
                        })
                    }
                }
                
            }
//            self.items.append(request)
            
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
