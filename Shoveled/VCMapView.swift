//
//  VCMapView.swift
//  Shoveled
//
//  Created by Joshua Walsh on 2/29/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation
import MapKit

extension CurrentStatusViewController: MKMapViewDelegate {
    
    //MARK: - MapView Delegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? ShovelAnnotation {
            let identifier = "ShovelAnnotation"
            var view: MKPinAnnotationView
            if let deqeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                deqeuedView.annotation = annotation
                view = deqeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: -5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let shovel = view.annotation as! ShovelAnnotation
        let title = shovel.userTitle
        let location = shovel.locationName
        
    }
}