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
    
    // Root API
    let ref = Firebase(url: "https://shoveled.firebaseio.com/")
    let locationRef = Firebase(url: "https://shoveled.firebaseio.com/shovel-locations")
    
    
    // MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        SwiftSpinner.show("Are those snowflakes?")
        getCurrentLocation()
        filterByProximity()
        configureView()
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
        rootRef.observeAuthEventWithBlock { (authData) -> Void in
            if authData == nil {
                self.performSegueWithIdentifier("notLoggedIn", sender: nil)
            }
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
        shovelRef.queryOrderedByChild("completed").observeEventType(.Value, withBlock: { snapshot in
            if let snapshot = snapshot {
                var newRequest = [ShovelRequest]()
                for item in snapshot.children {
                    let shovelItem = ShovelRequest(snapshot: item as! FDataSnapshot)
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
                            let mapAnnotation = ShovelAnnotation(address: shovelItem.address, coordinate: self.theirLocation, completed: false, price: shovelItem.price, details: shovelItem.details, shovelTime: shovelItem.shovelTime)
                            
                            self.mapView.addAnnotation(mapAnnotation)
  
                        } 
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
        ref.observeEventType(.Value, withBlock: { snapshot in
            
            var requestItem = [ShovelRequest]()
            for item in snapshot.children {

            }
            self.items = requestItem
            
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
