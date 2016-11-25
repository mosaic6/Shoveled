//
//  ForecastService.swift
//  Shoveled
//
//  Created by Joshua Walsh on 10/14/15.
//  Copyright © 2015 Lucky Penguin. All rights reserved.
//

import Foundation

struct ForecastService {

    let forecastAPIKey: String
    let forecastBaseURL: URL?

    init(APIKey: String) {
        forecastAPIKey = APIKey
        forecastBaseURL = URL(string: "https://api.forecast.io/forecast/\(forecastAPIKey)/")
    }

    func getForecast(_ lat: Double, lon: Double, completion: @escaping ((Forecast?) -> Void)) {

        if let forecastURL = URL(string: "\(lat),\(lon)", relativeTo: forecastBaseURL) {
            let networkOperation = NetworkOperation(url: forecastURL)

            networkOperation.downloadJSONFromURL {
                (JSONDictionary) in
                let forecast = Forecast(weatherDictionary: JSONDictionary)
                completion(forecast)
            }
        }
    }

}
