//
//  Place.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 25/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import Unbox

final class Place : Unboxable {
    let id: String
    let name: Variable<String>
    let street: Variable<String?>
    let city: Variable<String?>
    let photoURL: Variable<URL?>
    let events: Variable<[Event]>
    let loc: Variable<Loc?>
    let sportCategories: Variable<[Category]>

    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "_id")
        let name : String = try unboxer.unbox(key: "name")
        self.name = Variable<String>(name)
        let photoUrl : URL? = try? unboxer.unbox(key: "photoURL")
        self.photoURL = Variable<URL?>(photoUrl)
        let street : String? = try? unboxer.unbox(key: "street")
        self.street = Variable<String?>(street)
        var city : String? = try? unboxer.unbox(key: "city")
        city = (city != nil) ? city!.appending(", Polska") : "Warszawa, Polska"
        self.city = Variable<String?>(city)

        let events : [Event]? = unboxer.unbox(key: "events")
        if let events = events {
            self.events = Variable<[Event]>(events)
        } else {
            self.events = Variable<[Event]>([ ])
        }
        
        let loc: Loc? = try? unboxer.unbox(key: "loc")
        self.loc = Variable<Loc?>(loc)
        
        let sportsCategories: [Category]? = try? unboxer.unbox(key: "sportCategories")
        if let sportsCategories = sportsCategories {
            self.sportCategories = Variable<[Category]>(sportsCategories)
        } else {
            self.sportCategories = Variable<[Category]>([ ])
        }

    }
}
