//
//  APIError.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 22/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation

enum APIError : Error {
    case request(RequestError)
    case response(ResponseError)
    case serialization(SerializationError)
    case unknown(Error)
    
    var description: String {
        switch self {
        case .request(let err):
            return err.description
        case .response(let err):
            return err.description
        case .serialization(let err):
            return err.description
        case .unknown(let err):
            return err.localizedDescription
        }
    }
}
