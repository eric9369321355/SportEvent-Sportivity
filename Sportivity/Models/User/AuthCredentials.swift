//
//  AuthCredentials.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 23/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import Unbox
import Wrap

struct AuthCredentials : Unboxable {
    let id: String
    let token: String
    
    init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(key: "id")
        token = try unboxer.unbox(key: "token")
    }
    
    init(id: String, token: String) {
        self.id = id
        self.token = token
    }
}
