//
//  GamesViewModel.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 18/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Result

enum EventsFetchResult {
    case success
    case error(String)
    
    init(result: Result<[Event], APIError>) {
        switch result {
        case .success(_):
            self = .success
        case .failure(let error):
            self = .error(error.description)
        }
    }
}

class EventsViewModel {

    fileprivate let disposeBag = DisposeBag()
    fileprivate let userManager : UserManagerProtocol
    fileprivate let _events = Variable<[EventViewModel]>([ ])

    let events: Observable<[EventViewModel]> = PublishSubject<[EventViewModel]>()
    //let categories: Driver<[String: Bool]>
    
    let filterViewModel : CategoriesSelectionViewModel
    
    init(userManager: UserManagerProtocol = UserManager.shared) {
        self.userManager = userManager
        //self.categories = userManager.categorySelections.rx_selections
        self.filterViewModel = CategoriesSelectionViewModel(selections: userManager.categorySelections)
        // TODO: get the categories, listen to changes and fetch for every change
        
        Observable
            .combineLatest(_events.asObservable(), filterViewModel.selections.asObservable(), resultSelector: { (events, selections) -> [EventViewModel] in
                return events.filter({ (event) -> Bool in
                    guard let cat = event.category.value else { return false }
                    return selections.reduce(false, { (result, categorySelectionVM) -> Bool in
                        return result || (categorySelectionVM.category.rawValue == cat.rawValue && categorySelectionVM.isSelected)
                    })
                })
            })
            .bind(to: events.asPublishSubject()!)
            .addDisposableTo(disposeBag)
        
        _ = fetch()
    }
    
    func fetch() -> Observable<EventsFetchResult> {
        let categories : [String] = [ ]
        let params = EventsParameters(howMany: nil, from: nil, categories: categories, name: nil)
        let observable = EventsAPI.rx_fetchEvents(with: params).share()
        
        observable
            .map { (result) -> [EventViewModel] in
                var vms = [EventViewModel]()
                switch result {
                case .success(let events):
                    for event in events {
                        let vm = EventViewModel(event: event)
                        vms.append(vm)
                    }
                default:
                    break
                }
                return vms
            }
            .bind(to: _events)
            .addDisposableTo(disposeBag)
        
        return observable.map { (result) -> EventsFetchResult in
            return EventsFetchResult(result: result)
        }
    }
}
