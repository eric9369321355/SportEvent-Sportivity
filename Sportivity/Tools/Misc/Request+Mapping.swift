//
//  Request+Mapping.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 21/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import Unbox

extension DataRequest {
    
    func rx_responseModel<T: Unboxable>(_ type: T.Type, at location: String = "data") -> Observable<T> {
        return self
            .rx_responseJSON()
            .flatMap { (response, json) -> Observable<T> in
                guard let dict = json as? [ String: Any ] else {
                    Logger.shared.log(.warning, className: String(describing: type(of: self)), message: "Couldn't serialize \(T.self) from JSON")
                    return Observable.error(SerializationError.serializationError(response: response))
                }
                
                do {
                    let mappedModel: T = try (location.isEmpty ? unbox(dictionary: dict) : unbox(dictionary: dict, atKey: location))
                    return Observable.just(mappedModel)
                } catch let error as UnboxError {
                    Logger.shared.log(.info, className: String(describing: type(of: self)), message: "Mapping for \(T.self) failed! \(error.description)")
                    return Observable.error(SerializationError.mappingError(error: error, type: T.self))
                }
            }
            .shareReplay(1)
    }
    
    func rx_responseModelsArray<T: Unboxable>(_ type: T.Type, at location: String = "data") -> Observable<[T]> {
        return self
            .rx_responseJSON()
            .flatMap { (response, json) -> Observable<[T]> in
                guard let dict = json as? [ String: Any ] else {
                    Logger.shared.log(.warning, className: String(describing: type(of: self)), message: "Couldn't serialize array of \(T.self) from JSON")
                    return Observable.error(SerializationError.serializationError(response: response))
                }
                
                do {
                    let mappedModel: [T] = try (location.isEmpty ? unbox(dictionaries: [dict]) : unbox(dictionary: dict, atKey: location))
                    return Observable.just(mappedModel)
                } catch let error as UnboxError {
                    Logger.shared.log(.verbose, className: String(describing: type(of: self)), message: "Mapping of array of \(T.self) objects failed! \(error.description)")
                    return Observable.error(SerializationError.mappingError(error: error, type: T.self))
                }
            }
            .shareReplay(1)
    }
    
    func rx_responseNone() -> Observable<Void> {
        return self
            .rx_responseData()
            .retry(2)
            .flatMap { (response, data) -> Observable<Void> in
                return Observable.just()
            }
            .shareReplay(1)
    }
    
    func rx_responseString() -> Observable<String> {
        return self
            .rx_responseString()
            .retry(2)
            .flatMap { (response, string) -> Observable<String> in
                return Observable.just(string)
                
            }
            .shareReplay(1)
    }
    
}

private extension DataRequest {
    
    func rx_responseData() -> Observable<(HTTPURLResponse, Data)> {
        return rx_responseResult(responseSerializer: DataRequest.dataResponseSerializer())
    }
    
    func rx_responseJSON(_ options: JSONSerialization.ReadingOptions = .allowFragments) -> Observable<(HTTPURLResponse, Any)> {
        return rx_responseResult(responseSerializer: DataRequest.jsonResponseSerializer(options: options))
    }

    func rx_responseString() -> Observable<(HTTPURLResponse, String)> {
        return rx_responseResult(responseSerializer: DataRequest.stringResponseSerializer())
    }
    
    func rx_responseResult<T: DataResponseSerializerProtocol>(queue: DispatchQueue? = nil, responseSerializer: T) -> Observable<(HTTPURLResponse, T.SerializedObject)> {
        return Observable.create { observer in
            let dataRequest = self.response(queue: queue, responseSerializer: responseSerializer) {
                (packedResponse) -> Void in
                switch packedResponse.result {
                case .success(let result):
                    if let httpResponse = packedResponse.response {
                        // Logger
                        if let request = packedResponse.request, let method = request.httpMethod, let urlString = httpResponse.url?.relativeString {
                            let infoLog = "\(method) \(urlString) (\(httpResponse.statusCode))"
                            Logger.shared.log(.info, className: String(describing: type(of: self)), message: infoLog)
                            if let value = packedResponse.result.value {
                                //let verboseLog = infoLog + " Response: \n\(value)"
                                let verboseLog = "Response: \n\(value)"
                                Logger.shared.log(.verbose, className: String(describing: type(of: self)), message: verboseLog)
                            }
                        }
                        // Finish succesfully
                        observer.onNext((httpResponse, result))
                    } else {
                        // May be fragile, but this should actually never happen...
                        Logger.shared.log(.verbose, className: String(describing: type(of: self)), message: "Request finished with success, but we got some unexpected results.")
                        observer.onError(ResponseError(code: (packedResponse.response?.statusCode)!, message: nil))
                    }
                    observer.onCompleted()
                case .failure(let error): // We have failure, but we also may have some descriptive error from backend...
                    guard
                        let statusCode = packedResponse.response?.statusCode,
                        let data = packedResponse.data
                        else {
                            // Handle URLError
                            if let err = error as? URLError {
                                let requestError = RequestError(urlError: err)
                                Logger.shared.log(.error, className: String(describing: type(of: self)), message: "Status code is missing for error: \(requestError.description)")
                                observer.onError(requestError)
                                return
                            }
                            
                            // We don't have statusCode and data, so just return what've got from Alamofire
                            Logger.shared.log(.warning, className: String(describing: type(of: self)), message: "Status code is missing for error: \(self.debugDescription)")
                            observer.onError(error)
                            return
                    }
                    
                    // First let's try to serialize response as JSON dictionary
                    if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                        
                        // Is it a simple String
                        if let stringMessage = json as? String {
                            // Logger
                            var infoLog = "Request failed with \(statusCode): \(stringMessage)"
                            if let request = packedResponse.request, let method = request.httpMethod, let urlString = request.url?.relativeString {
                                infoLog = "\(method) \(urlString) (\(statusCode)): \(stringMessage)"
                            }
                            Logger.shared.log(.info, className: String(describing: type(of: self)), message: infoLog)
                            observer.onError(ResponseError(code: statusCode, message: stringMessage))
                            
                            // If it's a dictionary with `message` field as String, try to extract message
                        } else if let dict = json as? [String: Any], let stringMessage = dict["message"] as? String {
                            // Logger
                            var infoLog = "Request failed with \(statusCode): \(stringMessage)"
                            if let request = packedResponse.request, let method = request.httpMethod, let urlString = request.url?.relativeString {
                                infoLog = "\(method) \(urlString) (\(statusCode)): \(stringMessage)"
                            }
                            Logger.shared.log(.info, className: String(describing: type(of: self)), message: infoLog)
                            observer.onError(ResponseError(code: statusCode, message: stringMessage))
                            
                            // If it's a dictionary with `error` field as String, try to extract message
                        } else if let dict = json as? [String: Any], let stringMessage = dict["error"] as? String {
                            // Logger
                            var infoLog = "Request failed with \(statusCode): \(stringMessage)"
                            if let request = packedResponse.request, let method = request.httpMethod, let urlString = request.url?.relativeString {
                                infoLog = "\(method) \(urlString) (\(statusCode)): \(stringMessage)"
                            }
                            Logger.shared.log(.info, className: String(describing: type(of: self)), message: infoLog)
                            observer.onError(ResponseError(code: statusCode, message: stringMessage))
                            
                            // It's something different, so just return error with http status code only
                        } else {
                            print(json)
                            // Logger
                            var infoLog = "Request failed with \(statusCode) and no message"
                            if let request = packedResponse.request, let method = request.httpMethod, let urlString = request.url?.relativeString {
                                infoLog = "\(method) \(urlString) (\(statusCode)) and no message"
                            }
                            Logger.shared.log(.info, className: String(describing: type(of: self)), message: infoLog)
                            observer.onError(ResponseError(code: statusCode, message: nil))
                        }
                        
                        // If JSON serialization fails, let's try with simple String
                    } else if let stringErrorMessage = String(data: data, encoding: .utf8) {
                        // Logger
                        var infoLog = "Request failed with \(statusCode): \(stringErrorMessage)"
                        if let request = packedResponse.request, let method = request.httpMethod, let urlString = request.url?.relativeString {
                            infoLog = "\(method) \(urlString) (\(statusCode)): \(stringErrorMessage)"
                        }
                        Logger.shared.log(.info, className: String(describing: type(of: self)), message: infoLog)
                        observer.onError(ResponseError(code: statusCode, message: stringErrorMessage))
                        
                        // If it doesn't match anything, just create error with status code only
                    } else {
                        // Logger
                        var infoLog = "Request failed with \(statusCode) and no message"
                        if let request = packedResponse.request, let method = request.httpMethod, let urlString = request.url?.relativeString {
                            infoLog = "\(method) \(urlString) (\(statusCode)) and no message"
                        }
                        Logger.shared.log(.info, className: String(describing: type(of: self)), message: infoLog)
                        observer.onError(ResponseError(code: statusCode, message: nil))
                    }
                }
            }
            
            return Disposables.create {
                dataRequest.cancel()
            }
        }
    }
    
}
