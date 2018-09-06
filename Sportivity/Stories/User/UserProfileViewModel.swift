//
//  UserViewModel.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 19/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Result

enum UserProfileViewModelFetchResult {
    case sucess
    case error(String)
    
    init(result: Result<User, APIError>) {
        switch result {
        case .success:
            self = .sucess
        case .failure(let error):
            self = .error(error.localizedDescription)
        }
    }
}

class UserProfileViewModel {
    
    fileprivate var user : User?
    fileprivate let userManager : UserManagerProtocol
    
    let id: String
    let cellsData = Variable<[Any]>([ ])
    let isItMe: Variable<Bool>
    let disposeBag = DisposeBag()
    
    init(id: String, user: User?, userManager: UserManagerProtocol = UserManager.shared) {
        self.id = id
        self.userManager = userManager
        isItMe = Variable<Bool>(self.userManager.user?.id == id)
        if let user = user {
            self.user = user
            configure(with: user)
        }
        self.userManager
            .rx_user
            .subscribeNext { [unowned self] (user) in
                guard let user = user else { return }
                self.configure(with: user)
            }
            .addDisposableTo(disposeBag)
        _ = refresh()
    }
    
    func refresh() -> Observable<UserProfileViewModelFetchResult> {
        let observable = UserAPI.rx_fetchUser(id).share()
        observable.subscribeNext { [unowned self] (result) in
            switch result {
            case .success(let user):
                self.isItMe.value ? self.userManager.update(user: user) : self.configure(with: user)
            default:
                break
            }
        }
        .addDisposableTo(disposeBag)
        return observable.map { UserProfileViewModelFetchResult(result: $0) }
    }
    
    func logout() {
        userManager.logout()
    }
}

private extension UserProfileViewModel {
    func configure(with user: User) {
        self.user = user
        var cells = [Any]()
        let header = UserProfileHeaderViewModel(user: user, isItMe: isItMe)
        cells.append(header)
        for event in user.events.value {
            cells.append(EventViewModel(event: event))
        }
        cellsData.value = cells
    }
}
