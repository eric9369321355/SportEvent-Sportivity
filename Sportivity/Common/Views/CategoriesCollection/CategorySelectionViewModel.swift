//
//  CategorySelectionViewModel.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 01/06/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CategorySelectionViewModel {
    let category: Category
    let isSelected: Bool
    
    init(category: Category, isSelected: Bool) {
        self.category = category
        self.isSelected = isSelected
    }
}
