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
    
    var stripeKey: String {
        switch self {
        case .staging:
            return "pk_test_sInJmSxsoYOl5rPAv45pvwCv"
        case .production:
            return "pk_live_xvZp8nbvhuCB3pIrykXwZOEn"
        }
    }
    
    var stripeAuthToken: String {
        switch self {
        case .staging:
            return "Bearer sk_test_PbH5UZ20DwkBVbf6qWeOHSfh"
        case .production:
            return "Bearer sk_live_2CJnnLPGLtpNAzd3JB1xaojf"
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
