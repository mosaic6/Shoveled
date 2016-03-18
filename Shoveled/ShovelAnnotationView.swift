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
    let locationName: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName?.uppercaseString
    }
        
}