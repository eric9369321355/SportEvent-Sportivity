//
//  PlaceProfileHeaderViewModel.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 09/07/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PlaceProfileHeaderViewModel {
    fileprivate let place: Place
    fileprivate let disposeBag = DisposeBag()
    
    let id: String
    let name: Driver<String>
    let photoUrl: Driver<URL?>
    let loc: Driver<Loc?>
    let street: Driver<String?>
    let city: Driver<String?>
    let categories: Driver<[Category]>
    
    init(place: Place, userManager: UserManagerProtocol = UserManager()) {
        self.place = place
        self.id = place.id
        
        self.name = self.place.name.asDriver()
        self.photoUrl = self.place.photoURL.asDriver()
        self.loc = self.place.loc.asDriver()
        self.street = self.place.street.asDriver()
        self.city = self.place.city.asDriver()
        self.categories = self.place.sportCategories.asDriver()
    }
}
