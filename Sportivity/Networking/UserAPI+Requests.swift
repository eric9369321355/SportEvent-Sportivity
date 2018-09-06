//
//  UserAPI+Requests.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 21/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import Wrap
import Result

extension UserAPI {
    static func rx_fetchUser(_ id: String) -> Observable<Result<User, APIError>> {
        return UserAPI
            .fetch(user: id)
            .validatedRequest()
            .rx_responseModel(User.self)
            .resultifyAPIResponse()
    }
    
    static func rx_search(name: String?, howMany: Int) -> Observable<[User]> {
        return UserAPI
            .search(name: name, howMany: howMany)
            .validatedRequest()
            .rx_responseModelsArray(User.self)
    }
    
    static func rx_create(name: String, email: String, pass: String) -> Observable<User> { // Observable<Result<User, APIError>> {
        return UserAPI
            .create(name: name, email: email, password: pass)
            .validatedRequest()
            .rx_responseModel(User.self)
//            .resultifyAPIResponse()
    }
}
