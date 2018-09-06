//
//  EditUserViewModel.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 10/07/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class EditUserViewModel {
    fileprivate let userManager: UserManagerProtocol
    
    let name: Variable<String>
    let photoURL: Variable<URL?>
    let email: Variable<String?>
    let sports: Variable<[Category]>
    let newPassword = Variable<String?>(nil)
    
    init(userManager: UserManagerProtocol = UserManager.shared) {
        self.userManager = userManager
        let user = userManager.user!
        self.name = user.name
        self.photoURL = user.photoUrl
        self.email = user.email
        self.sports = user.sportCategories
    }
    
    func save() -> Observable<Void> {
        let user = userManager.user!
        self.userManager.update(user: user)
        return Observable<Void>.just().delay(1, scheduler: MainScheduler.instance)
    }
}
