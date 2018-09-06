//
//  RequestError.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 21/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation

enum RequestError: SportivityError {
    case noInternetConnection
    case timeout
    case networkConnectionLost
    case cancelled
    case unknown
    
    init(urlError: URLError) {
        switch urlError.code {
        case .notConnectedToInternet:
            self = .noInternetConnection
        case .timedOut:
            self = .timeout
        case .networkConnectionLost:
            self = .networkConnectionLost
        case .internationalRoamingOff:
            // NOTE: treating "no roaming" erorr as "no internet"
            self = .noInternetConnection
        case .cancelled:
            self = .cancelled
        default:
            self = .unknown
        }
    }
    
    var description: String {
        switch self {
        case .noInternetConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .networkConnectionLost:
            return "Connection lost"
        case .cancelled:
            return "Request cancelled"
        case .unknown:
            return self.defaultMessage
        }
    }
}
