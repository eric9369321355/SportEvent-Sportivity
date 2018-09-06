//
//  User.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 21/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import Unbox
import RxSwift
import Wrap

struct User: Unboxable {
    
    let id: String
    let email = Variable<String?>("")
    let name = Variable<String>("")
    let city = Variable<String?>(nil)
    let photoUrl = Variable<URL?>(nil)
    let isFollowing = Variable<Bool>(false)
    let sportCategories: Variable<[Category]>
    let events: Variable<[Event]>
    let token : String?
    
    init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(key: "_id")
        email.value = try? unboxer.unbox(key: "email")
        name.value = try unboxer.unbox(key: "name")
        city.value = unboxer.unbox(key: "city")
        photoUrl.value = unboxer.unbox(key: "photoURL")
        let isFollowing: Bool? = try? unboxer.unbox(key: "isFriend")
        self.isFollowing.value = isFollowing ?? false
        
        let categories: [Category]? = try? unboxer.unbox(key: "sportsCategories")
        self.sportCategories = Variable<[Category]>(categories ?? [Category]())
        
        let events: [Event]? = try? unboxer.unbox(key: "events")
        self.events = Variable<[Event]>(events ?? [Event]())
        
        token = unboxer.unbox(key: "token")
    }
}

extension User: WrapCustomizable {
    func keyForWrapping(propertyNamed propertyName: String) -> String? {
        switch propertyName {
        case "id":                  return "_id"
        case "name":                return "name"
        //case "photoUrl":            return "photoURL"
        case "email":               return "email"
        case "city":                return "city"
        case "sportCategories":     return "sportsCategories"
        default:                    return nil
        }
    }
    
    func wrap(propertyNamed propertyName: String, originalValue: Any, context: Any?, dateFormatter: DateFormatter?) throws -> Any? {
        switch propertyName {
        case "id":                  return originalValue
        case "name":                return (originalValue as! Variable<String>).value
        case "photoURL":            return (originalValue as! Variable<URL?>).value?.absoluteString
        case "email":               return (originalValue as! Variable<String?>).value
        case "city":                return (originalValue as! Variable<String?>).value
        case "sportCategories":     return (originalValue as! Variable<[Category]>).value.map { $0.rawValue }
        default:                    return nil
        }
    }
}
