//
//  EventViewModel+ListingProtocol.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 07/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension EventViewModel : ListingViewModelProtocol {
        
    var id : String {
        return identity
    }
    
    var title : Driver<String> {
        return name
    }
    
    var imageUrl : Driver<URL?> {
        return photoUrl
    }
}

func ==(lhs: EventViewModel, rhs: EventViewModel) -> Bool {
    return lhs.identity == rhs.identity
}
