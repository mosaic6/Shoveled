//
//  ShovelAnnotationView.swift
//  Shoveled
//
//  Created by Joshua Walsh on 2/23/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import MapKit

class ShovelAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let completed: Bool
    let accepted: Bool
    let price: String?
    let details: String?
    let shovelTime: String?
    
    init(address: String, coordinate: CLLocationCoordinate2D, completed: Bool, accepted: Bool, price: String, details: String, shovelTime: String) {
        self.title = address
        self.coordinate = coordinate
        self.completed = completed
        self.accepted = accepted
        self.price = price
        self.details = details
        self.shovelTime = shovelTime
        
        super.init()
    }
    
    var subtitle: String? {
        return details?.uppercaseString
    }
        
}