//
//  NetworkingHelpers.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 21/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

/// Base protocol for any PartyHype networking router
protocol NetworkHelpers: URLRequestConvertible {
    var baseURLString: String { get }
    var method: Alamofire.HTTPMethod { get }
    var relativePath: String? { get }
    var parameters: Alamofire.Parameters? { get }
    var parametersEncoding: Alamofire.ParameterEncoding { get }
}

// MARK: - Default implementation for URLRequestConvertible
extension NetworkHelpers {
    func asURLRequest() throws -> URLRequest {
        var URL = Foundation.URL(string: baseURLString)!
        if let relativePath = relativePath {
            #if swift(>=2.3)
                URL = URL.appendingPathComponent(relativePath)
            #else
                URL = URL.URLByAppendingPathComponent(relativePath)
            #endif
        }
        
        var urlRequest = URLRequest(url: URL)
        urlRequest.httpMethod = method.rawValue
        
        if let token = UserManager.shared.token {
            urlRequest.setValue("\(token)", forHTTPHeaderField: "x-access-token")
        } else {
            Logger.shared.log(.warning, className: String(describing: type(of: self)), message: "Access token is missing during NSMutableURLRequest creation")
        }
        
        return try parametersEncoding.encode(urlRequest, with: parameters)
    }
}


extension URLRequestConvertible {
    
    ///  Converts URLRequestConvertible to Request.
    ///
    ///  - returns: Request.
    func request() ->  DataRequest {
        return Alamofire.request(self).log()
    }
    
    ///  Converts URLRequestConvertible to Request with additional HTTP status validation
    ///
    ///  - returns: Requests.
    func validatedRequest() -> DataRequest {
        return self.request().validate(statusCode: 200 ..< 300)
    }
}

extension DataRequest {
    func log() -> Self {
        let message = self.debugDescription
        Logger.shared.log(.verbose, message: message)
        return self
    }
}
