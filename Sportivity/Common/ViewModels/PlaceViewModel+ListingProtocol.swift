//
//  PlaceViewModel+ListingProtocol.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 10/07/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension PlaceViewModel : ListingViewModelProtocol {
    
    var title : Driver<String> {
        return name
    }
    
    var imageUrl : Driver<URL?> {
        return photoUrl
    }
}

func ==(lhs: PlaceViewModel, rhs: PlaceViewModel) -> Bool {
    return lhs.identity == rhs.identity
}
