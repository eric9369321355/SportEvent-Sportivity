//
//  AuthenitcateAPI.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 21/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import Alamofire

enum AuthenticateAPI {
    case login(email: String, password: String)
}

extension AuthenticateAPI: NetworkHelpers {
    var baseURLString: String {
        return Config.APIBaseURL + "/authenticate"
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .login:
            return .post
        }
    }
    
    var relativePath: String? {
        switch self {
        case .login:
            return nil
        }
    }
    
    var parameters: Alamofire.Parameters? {
        switch self {
        case .login(let email, let pass):
            return ["email": email, "password": pass]
        }
    }
    
    var parametersEncoding: Alamofire.ParameterEncoding {
        switch self {
        case .login:
            return JSONEncoding.default
        }
    }
}

