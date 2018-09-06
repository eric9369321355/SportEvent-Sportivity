//
//  PlaceAPI.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 08/06/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import Alamofire

enum PlacesAPI {
    case fetchAll
    case fetchPlace(id: String)
    case search(name: String?, howMany: Int)
}

extension PlacesAPI: NetworkHelpers {
    var baseURLString: String {
        return Config.APIBaseURL + "/places"
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchAll, .fetchPlace, .search:
            return .get
        }
    }
    
    var relativePath: String? {
        switch self {
        case .fetchAll, .search:
            return nil
        case .fetchPlace(let id):
            return "/\(id)"
        }
    }
    
    var parameters: Alamofire.Parameters? {
        switch self {
        case .fetchAll, .fetchPlace:
            return nil
        case .search(let name, let howMany):
            var params = [String: Any]()
            params["howMany"] = howMany
            if let name = name {
                params["name"] = name
            }
            return params
        }
    }
    
    var parametersEncoding: Alamofire.ParameterEncoding {
        switch self {
        case .fetchAll, .fetchPlace, .search:
            return URLEncoding.queryString
        }
    }
}
