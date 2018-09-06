//
//  AuthenitcateAPI+Requests.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 21/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import Result

extension AuthenticateAPI {
    static func rx_login(email: String, password: String) -> Observable<Result<User, APIError>> {
        return AuthenticateAPI.login(email: email, password: password)
            .validatedRequest()
            .rx_responseModel(User.self)
            .resultifyAPIResponse()
    }
}
