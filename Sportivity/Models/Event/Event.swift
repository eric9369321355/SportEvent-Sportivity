//
//  Event.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 18/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import Unbox

final class Event : Unboxable {
    let id: String
    let name: Variable<String>
    let photoUrl: Variable<URL?>
    let attendees: Variable<[EventAttendee]>
    let dateStart: Variable<Date>
    let dateEnd: Variable<Date?>
    let capacity: Variable<Int?>
    let host: Variable<User?>
    let place: Variable<Place?>
    let sportCategory: Variable<Category?>
    
    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "_id")
        let name : String = try unboxer.unbox(key: "name")
        self.name = Variable<String>(name)
        let photoUrl : URL? = try? unboxer.unbox(key: "photoURL")
        self.photoUrl = Variable<URL?>(photoUrl)
        
        let attendees : [EventAttendee]? = unboxer.unbox(key: "attendees")
        if let attendees = attendees {
            self.attendees = Variable<[EventAttendee]>(attendees)
        } else {
            self.attendees = Variable<[EventAttendee]>([ ])
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        let dateStart : Date = try unboxer.unbox(key: "dateStart", formatter: dateFormatter)
        self.dateStart = Variable<Date>(dateStart)
        let dateEnd : Date? = try? unboxer.unbox(key: "dateEnd", formatter: dateFormatter)
        self.dateEnd = Variable<Date?>(dateEnd)
        
        let capacity : Int? = try? unboxer.unbox(key: "capacity")
        self.capacity = Variable<Int?>(capacity)
        
        let host : User? = try? unboxer.unbox(key: "host")
        self.host = Variable<User?>(host)
        let place : Place? = try? unboxer.unbox(key: "place")
        self.place = Variable<Place?>(place)
        
        let cat: Category? = try? unboxer.unbox(key: "sportCategory")
        self.sportCategory = Variable<Category?>(cat)
    }
}
