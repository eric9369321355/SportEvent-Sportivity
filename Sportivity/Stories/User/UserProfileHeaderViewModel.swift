//
//  UserHeaderViewModel.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 19/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class UserProfileHeaderViewModel {
    
    let name: Driver<String>
    let photoURL: Driver<URL?>
    let followers : Driver<String> = Driver.just("12 Followers / 8 Following")
    let isFollowing: Variable<Bool>
    let isItMe: Variable<Bool>
    let sports: Driver<[Category]>
    
    init(user: User, isItMe: Variable<Bool>) {
        self.name = user.name.asDriver()
        self.photoURL = user.photoUrl.asDriver()
        self.isFollowing = user.isFollowing
        self.isItMe = isItMe
        self.sports = user.sportCategories.asDriver()
    }
}
