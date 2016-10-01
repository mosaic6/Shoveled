//
//  Icon.swift
//  Shoveled
//
//  Created by Joshua Walsh on 10/14/15.
//  Copyright © 2015 Lucky Penguin. All rights reserved.
//

import Foundation
import UIKit

enum Icon: String {
    case ClearDay = "clear-day"
    case ClearNight = "clear-night"
    case Rain = "rain"
    case Snow = "snow"
    case Sleet = "sleet"
    case Wind = "wind"
    case Fog = "fog"
    case Cloudy = "cloudy"
    case PartlyCloudyDay = "partly-cloudy-day"
    case PartlyCloudyNight = "partly-cloudy-night"
    
    func toImage() -> (regularIcon: UIImage?, largeIcon: UIImage?) {
        var imageName: String
        
        switch self {
        case .ClearDay:
            imageName = "ClearDay"
        case .ClearNight:
            imageName = "ClearNight"
        case .Rain:
            imageName = "Showers"
        case .Snow:
            imageName = "Moresnow"
        case .Sleet:
            imageName = "Sleet"
        case .Wind:
            imageName = "Windy"
        case .Fog:
            imageName = "Dayfog"
        case .Cloudy:
            imageName = "Mostcloudsday"
        case .PartlyCloudyDay:
            imageName = "Mostcloudsday"
        case .PartlyCloudyNight:
            imageName = "Mostcloudsday"
        }
        
        let regularIcon = UIImage(named: "\(imageName).pdf")
        let largeIcon = UIImage(named: "\(imageName).pdf")
        return (regularIcon, largeIcon)
    }
}
