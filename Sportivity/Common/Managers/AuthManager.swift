//
//  AuthManager.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 23/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import Unbox
import Wrap

protocol AuthManagerProtocol {
    var rx_credentials : Observable<AuthCredentials?> { get }
    var credentials : AuthCredentials? { get }
    func save(id: String, token: String) throws
    func clear()
}

private struct C {
    static let storedCredentials = "credentials"
}

class AuthManager : AuthManagerProtocol {
    
    // MARK: - Public properties
    
    static let instance = AuthManager()
    var credentials : AuthCredentials? {
        return _credentials.value
    }
    var rx_credentials : Observable<AuthCredentials?> {
        return _credentials.asObservable()
    }
    
    // MARK: - Private
    
    fileprivate let _credentials = Variable<AuthCredentials?>(nil)
    
    private init() {
        do {
            guard let stored = try read() else { return }
            _credentials.value = stored
        } catch let error {
            Logger.shared.log(.error, message: "Reading (unboxing) credentials failed. Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Public methods
    
    func save(id: String, token: String) throws {
        Logger.shared.log(.info, message: "Saving AuthCredential for user: \(id)")
        assert(!id.isEmpty && !token.isEmpty)
        let new = AuthCredentials(id: id, token: token)
        do {
            let dict : [String: Any] = try wrap(new)
            UserDefaults.standard.setValue(dict, forKey: C.storedCredentials)
            UserDefaults.standard.synchronize()
            _credentials.value = new
        } catch let error {
            Logger.shared.log(.error, message: "Saving (wrapping) credentials failed. Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func clear() {
        Logger.shared.log(.info, message: "Clearing AuthCredentials")
        UserDefaults.standard.removeObject(forKey: C.storedCredentials)
        UserDefaults.standard.synchronize()
        _credentials.value = nil
    }
}

private extension AuthManager {
    func read() throws -> AuthCredentials? {
        Logger.shared.log(.info, message: "Reading AuthCredentials")
        let dict = UserDefaults.standard.dictionary(forKey: C.storedCredentials)
        guard let dictionary = dict else { return nil }
        let credentials : AuthCredentials = try unbox(dictionary: dictionary)
        return credentials
    }
}
