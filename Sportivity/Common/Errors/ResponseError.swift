//
//  ResponseError.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 21/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation

enum ResponseError: SportivityError {
    case badRequest(code: Int, message: String?)
    case forbidden(code: Int, message: String?)
    case notFound(code: Int, message: String?)
    case unauthorized(code: Int, message: String?)
    case conflict(code: Int, message: String?)
    case unrecognizedFailureStatusCode(code: Int, message: String?)
    case unrecognizedSuccessStatusCode(code: Int, message: String?)
    
    var code : Int {
        switch self {
        case let .badRequest(code, _):
            return code
        case let .unauthorized(code, _):
            return code
        case let .forbidden(code, _):
            return code
        case let .notFound(code, _):
            return code
        case let .conflict(code, _):
            return code
        case let .unrecognizedSuccessStatusCode(code, _):
            return code
        case let .unrecognizedFailureStatusCode(code, _):
            return code
        }
    }
    
    init(code: Int, message: String?) {
        switch code {
        case 400:
            self = .badRequest(code: code, message: message)
        case 401:
            self = .unauthorized(code: code, message: message)
        case 403:
            self = .forbidden(code: code, message: message)
        case 404:
            self = .notFound(code: code, message: message)
        case 409:
            self = .conflict(code: code, message: message)
        case 200..<300:
            self = .unrecognizedSuccessStatusCode(code: code, message: message)
        default:
            self = .unrecognizedFailureStatusCode(code: code, message: message)
        }
    }
    
    var description: String {
        func defaultMessageWithStatusCode(_ code: Int) -> String {
            return self.defaultMessage + " (\(code))"
        }
        
        switch self {
        case let .badRequest(code, message):
            return message ?? defaultMessageWithStatusCode(code)
        case let .unauthorized(code, message):
            return message ?? defaultMessageWithStatusCode(code)
        case let .forbidden(code, message):
            return message ?? defaultMessageWithStatusCode(code)
        case let .notFound(code, message):
            return message ?? defaultMessageWithStatusCode(code)
        case let .conflict(code, message):
            return message ?? defaultMessageWithStatusCode(code)
        case let .unrecognizedSuccessStatusCode(code, message):
            return message ?? defaultMessageWithStatusCode(code)
        case let .unrecognizedFailureStatusCode(code, message):
            return message ?? defaultMessageWithStatusCode(code)
        }
    }
}
