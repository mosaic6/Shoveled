//
//  ShovelAnnotationView.swift
//  Shoveled
//
//  Created by Joshua Walsh on 2/23/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation
import MapKit

class ShovelAnnotation: NSObject, MKAnnotation {
    let userTitle: String
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.userTitle = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
        
}