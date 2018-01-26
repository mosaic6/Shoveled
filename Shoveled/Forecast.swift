//
//  Forecast.swift
//  Shoveled
//
//  Created by Joshua Walsh on 10/14/15.
//  Copyright © 2015 Lucky Penguin. All rights reserved.
//

import Foundation

struct Forecast {
    var currentWeather: CurrentWeather?
    var weekly: [DailyWeather] = []

    init(weatherDictionary: [String: AnyObject]?) {
        if let currentWeatherDictionary = weatherDictionary?["currently"] as? [String: AnyObject] {
            currentWeather = CurrentWeather(weatherDictionary: currentWeatherDictionary)
        }

        if let weeklyWeatherArray = weatherDictionary?["daily"]?["data"] as? [[String: AnyObject]] {
            for dailyWeather in weeklyWeatherArray {
                let daily = DailyWeather(dailyWeatherDict: dailyWeather)
                weekly.append(daily)
            }
        }
    }
}
