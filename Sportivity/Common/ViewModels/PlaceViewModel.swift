//
//  PlaceViewModel.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 10/07/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PlaceViewModel {
    
    // Properties needed to retain model. Otherwise these objects deallocate in the processes e.g. in Search and Driver properties do not emit any Sequences
    let place: Place?
    let id: String
    
    typealias Identity = String
    let identityID: String = UUID().uuidString
    var identity: String {
        return identityID
    }
    
    let name: Driver<String>
    let photoUrl: Driver<URL?>
    
    init(place: Place) {
        self.place = place
        self.id = place.id
        name = place.name.asDriver()
        photoUrl = place.photoURL.asDriver()
    }
}
