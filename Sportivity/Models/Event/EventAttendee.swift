//
//  EventAttendee.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 25/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import Unbox

final class EventAttendee : Unboxable {
    let id: String
    let name = Variable<String>("")
    let photoUrl = Variable<URL?>(nil)

    init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(key: "_id")
        name.value = try unboxer.unbox(key: "name")
        photoUrl.value = unboxer.unbox(key: "photoURL")
    }
    
    init(user: User) {
        self.id = user.id
        self.name.value = user.name.value
        self.photoUrl.value = user.photoUrl.value
    }
}
