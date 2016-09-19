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
    let latitude: NSNumber?
    let longitude: NSNumber?
    let status: String?
    let price: String?
    let details: String?
    let otherInfo: String?
    let addedByUser: String?
    let id: String?
    let createdAt: String?
    
    init(address: String, coordinate: CLLocationCoordinate2D, latitude: NSNumber, longitude: NSNumber, status: String, price: String, details: String, otherInfo: String, addedByUser: String, id: String, createdAt: String) {
        self.title = address
        self.coordinate = coordinate
        self.latitude = latitude
        self.longitude = longitude
        self.status = status
        self.price = price
        self.details = details
        self.otherInfo = otherInfo
        self.addedByUser = addedByUser
        self.id = id
        self.createdAt = createdAt  
        
    }
    
    var subtitle: String? {
        return status?.uppercaseString
    }
        
}