//
//  Config.swift
//  Shoveled
//
//  Created by Joshua Walsh on 12/22/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation

enum Environment: String {
    case staging = "staging"
    case production = "production"
    
    var baseURL: String {
        switch self {
        case .staging:
            guard let devPath = Bundle.main.path(forResource: "DEVGoogleService-Info", ofType: "plist") else { return "" }
            return devPath
        case .production:
            guard let prodPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else { return "" }
            return prodPath
        }
    }
}

struct Configuration {
    lazy var environment: Environment = {
        if let configuation = Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String {
            if configuation.range(of: "Staging") != nil {
                return Environment.staging
            }
        }
        return Environment.production
    }()
}
