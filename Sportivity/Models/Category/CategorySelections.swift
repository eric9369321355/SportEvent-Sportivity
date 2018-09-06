//
//  CategorySelection.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 19/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CategorySelections {
    
    private let _selections = Variable<[String: Bool]>([String: Bool]())
    let rx_selections: Driver<[String: Bool]>
    var selections: [String: Bool] {
        return _selections.value
    }
    let select = PublishSubject<String>()
    let deselect = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    var selectedCategories: [Category] {
        let selectedKeys = _selections.value.filter { return $1 }.map { (key: String, value: Bool) -> String in
            return key
        }
        let categories = selectedKeys.map { Category(rawValue: $0) }
        return categories.filter { $0 != nil }.map { $0! }
    }
    var rx_selectedCategories: Driver<[Category]> {
        let drv = _selections
            .asDriver()
            .map { dict -> [String] in
                return dict.filter({ (key: String, value: Bool) -> Bool in
                    return value == true
                }).map({ (key: String, value: Bool) -> String in
                    return key
                })
            }
            .flatMap({ (strings) -> SharedSequence<DriverSharingStrategy, [Category]> in
                let asd = strings
                    .map { Category(rawValue: $0) }
                    .filter { $0 != nil }
                    .map { $0! }
                return Driver.just(asd)
            })
        return drv
    }
    
    init(selected: [Category]?) {
        
        rx_selections = _selections.asDriver()
        select.asObservable().subscribeNext { [weak self] (category) in
            self?.set(category: category, selected: true)
        }
        .addDisposableTo(disposeBag)
        deselect.asObservable().subscribeNext { [weak self] (category) in
            self?.set(category: category, selected: false)
        }
        .addDisposableTo(disposeBag)
        
        let userCategories = selected ?? [Category]()
        set(categories: userCategories)
        
        rx_selections
            .driveNext { (cats) in
                let selected = cats.filter { $1 }.map { $0.key }
                Logger.shared.log(.debug, message: "CategorySelections changed to:\n- all: \(cats)\n- selected: \(selected)")
            }
            .addDisposableTo(disposeBag)
    }
    
    func set(categories: [Category]) {
        var selectionsDict = [String: Bool]()
        let all = Category.all()
        
        for category in all {
            selectionsDict[category.rawValue] = false
            for selection in categories {
                if selection.rawValue == category.rawValue {
                    selectionsDict[category.rawValue] = true
                    break
                }
            }
        }
        
        _selections.value = selectionsDict
    }
    
    func set(category: String, selected: Bool) {
        var selections = _selections.value
        selections[category] = selected
        _selections.value = selections
    }
}
