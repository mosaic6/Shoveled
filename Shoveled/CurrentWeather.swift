//
//  CurrentWeather.swift
//  Shoveled
//
//  Created by Joshua Walsh on 10/14/15.
//  Copyright © 2015 Lucky Penguin. All rights reserved.
//

import Foundation
import UIKit

struct CurrentWeather {

    let temperature: Double?
    let humidity: Int?
    let precipProbability: Int?
    let precipType: String?
    let summary: String?
    var icon: UIImage? = UIImage(named: "default.png")

    init(weatherDictionary: [String: AnyObject]) {
        self.temperature = weatherDictionary["temperature"] as? Double

        if let humidityFloat = weatherDictionary["humidity"] as? Double {
            humidity = Int(humidityFloat * 100)
        } else {
            humidity = nil
        }

        if let precipFloat = weatherDictionary["precipProbability"] as? Double {
            precipProbability = Int(precipFloat * 100)
        } else {
            precipProbability = nil
        }

        if let precipTypeString = weatherDictionary["precipType"] as? String {
            self.precipType = String(precipTypeString)
        } else {
            self.precipType = nil
        }

        summary = weatherDictionary["summary"] as? String

        if let iconString = weatherDictionary["icon"] as? String,
            let weatherIcon: Icon = Icon(rawValue: iconString) {
                (icon, _) = weatherIcon.toImage()
        }
    }
}
