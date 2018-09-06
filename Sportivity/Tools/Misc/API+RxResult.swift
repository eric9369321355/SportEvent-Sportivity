//
//  API+RxResult.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 23/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import Result
import RxSwift
import Unbox

extension Observable {
    func resultifyAPIResponse() -> Observable<Result<Element, APIError>> {
        return self
            .map { Result.success($0) }
            .catchError { (error) -> Observable<Result<Element, APIError>> in
                var apiError : APIError!
                if let err = error as? ResponseError {
                    apiError = .response(err)
                } else if let err = error as? RequestError {
                    apiError = .request(err)
                } else if let err = error as? SerializationError {
                    apiError = .serialization(err)
                } else {
                    Logger.shared.log(.error, className: "\(self)", message: "Unrecognized error type. Error: \"\(error.localizedDescription)\"")
                    apiError = .unknown(error)
                }
                return Observable<Result<Element, APIError>>.just(Result<Element, APIError>.failure(apiError))
        }
    }
}
