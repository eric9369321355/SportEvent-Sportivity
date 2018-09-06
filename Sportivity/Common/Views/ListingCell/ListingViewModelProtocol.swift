//
//  ListingProtocol.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 19/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxCocoa

protocol ListingViewModelProtocol {
    var id : String { get }
    var title : Driver<String> { get }
    var imageUrl : Driver<URL?> { get }
}
