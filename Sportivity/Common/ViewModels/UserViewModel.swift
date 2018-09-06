//
//  UserViewModel.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 25/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class UserViewModel: UserRouteData {
    
    // Properties needed to retain model. Otherwise these objects deallocate in the processes e.g. in Search and Driver properties do not emit any Sequences
    let user: User?
    let attendee: EventAttendee?
    
    let id: String
    typealias Identity = String
    let identityID: String = UUID().uuidString
    var identity: String {
        return identityID
    }
    
    let name: Driver<String>
    let photoUrl: Driver<URL?>
    
    init(user: User) {
        self.user = user
        self.attendee = nil
        self.id = user.id
        name = user.name.asDriver()
        photoUrl = user.photoUrl.asDriver()
    }
    
    init(attendee: EventAttendee) {
        self.attendee = attendee
        self.user = nil
        self.id = attendee.id
        name = attendee.name.asDriver()
        photoUrl = attendee.photoUrl.asDriver()
    }
}
