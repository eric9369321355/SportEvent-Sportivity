//
//  UserViewModel+ListingProtocol.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 25/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension UserViewModel : ListingViewModelProtocol {
    
    var title : Driver<String> {
        return name
    }
    
    var imageUrl : Driver<URL?> {
        return photoUrl
    }
}

//func ==(lhs: UserViewModel, rhs: UserViewModel) -> Bool {
//    return lhs.identity == rhs.identity
//}
