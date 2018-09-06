//
//  CategoriesSelectionViewModel.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 26/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CategoriesSelectionViewModel {
    fileprivate let _selections: CategorySelections
    let selections: Driver<[CategorySelectionViewModel]>
    let categorySelected = PublishSubject<Category>()
    let categoryDeselected = PublishSubject<Category>()
    fileprivate let disposeBag = DisposeBag()
    
    init(selections: CategorySelections) {
        self._selections = selections
        self.selections = selections.rx_selections.map { (dict) -> [CategorySelectionViewModel] in
            var arr = [CategorySelectionViewModel]()
            for (key, value) in dict {
                if let cat = Category(rawValue: key) {
                    arr.append(CategorySelectionViewModel.init(category: cat, isSelected: value))
                }
            }
            return arr
        }
        
        categorySelected
            .asObservable()
            .subscribeNext { [unowned self] (category) in
                self._selections.set(category: category.rawValue, selected: true)
            }
            .addDisposableTo(disposeBag)
        
        categoryDeselected
            .asObservable()
            .subscribeNext { [unowned self] (category) in
                self._selections.set(category: category.rawValue, selected: false)
            }
            .addDisposableTo(disposeBag)
    }
}
