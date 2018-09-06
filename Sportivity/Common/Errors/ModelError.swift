//
//  ModelError.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 21/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation

enum SerializationError: SportivityError {
    case serializationError(response: HTTPURLResponse?)
    case mappingError(error: Error, type: Any)
    case wrappingError(error: Error, type: Any)
    
    var description: String {
        return self.defaultMessage
    }
}
