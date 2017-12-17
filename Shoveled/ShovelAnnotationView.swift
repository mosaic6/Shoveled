//
//  ShovelAnnotationView.swift
//  Shoveled
//
//  Created by Joshua Walsh on 2/23/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import MapKit

class ShovelAnnotation: NSObject, MKAnnotation {
    let shovelRequest: ShovelRequest?
    let title: String?
    init(coordinate: CLLocationCoordinate2D, title: String, shovelRequest: ShovelRequest) {
        self.shovelRequest = shovelRequest
        self.title = shovelRequest.address
    }

    var subtitle: String? {
        guard let shovelRequest = self.shovelRequest else {
            return ""
        }
        return "\(shovelRequest.status.uppercased()) $\(shovelRequest.priceForShoveler)"
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var longitude: Double {
        return shovelRequest?.longitude ?? 0.0
    }

    var latitude: Double {
        return shovelRequest?.latitude ?? 0.0
    }

}
