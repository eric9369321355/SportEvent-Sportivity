//
//  UserAPI.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 21/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import Alamofire

enum UserAPI {
    case fetch(user: String)
    case search(name: String?, howMany: Int)
    case create(name: String, email: String, password: String)
}

extension UserAPI: NetworkHelpers {
    var baseURLString: String {
        return Config.APIBaseURL + "/users"
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .fetch, .search:
            return .get
        case .create:
            return .post
        }
    }
    
    var relativePath: String? {
        switch self {
        case .fetch(let id):
            return "/\(id)"
        case .search, .create:
            return nil
        }
    }
    
    var parameters: Alamofire.Parameters? {
        switch self {
        case .fetch:
            return nil
        case .search(let name, let howMany):
            var params = Alamofire.Parameters.init()
            params["howMany"] = howMany
            if let name = name {
                params["name"] = name
            }
            return params
        case .create(let name, let email, let password):
            var params = Alamofire.Parameters.init()
            params["name"] = name
            params["email"] = email
            params["password"] = password
            return params
        }
    }
    
    var parametersEncoding: Alamofire.ParameterEncoding {
        switch self {
        case .fetch, .search:
            return URLEncoding.queryString
        case .create:
            return JSONEncoding.default
        }
    }
}
