//
//  Errors.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 21/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation

protocol SportivityError : Error { }

extension SportivityError {
    var defaultMessage : String {
        return "Oops something went wrong..."
    }
}
