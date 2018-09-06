//
//  SearchViewModel.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 19/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum SearchType {
    case users
    case events
    case places
}

class SearchViewModel {
    let data = Variable<[ListingViewModelProtocol]>([ ])
    let type = Variable<SearchType>(.users)
    let searchQuery = Variable<String?>(nil)
    
    fileprivate let disposeBag = DisposeBag()
    
    init() {
        Observable
            .combineLatest(searchQuery.asObservable(), type.asObservable()) { (query, type) -> (String?, SearchType) in
                return (query, type)
            }
            .flatMap { (name: String?, type: SearchType) -> Observable<[ListingViewModelProtocol]> in
                return self.fetch(name: name, of: type).catchErrorJustReturn([ListingViewModelProtocol]()).startWith([ListingViewModelProtocol]())
            }
            .bind(to: data)
            .addDisposableTo(disposeBag)
    }
    
    private func fetch(name query: String?, of type: SearchType) -> Observable<[ListingViewModelProtocol]> {
        var obs : Observable<[ListingViewModelProtocol]>!
        switch type {
        case .users:
            obs = UserAPI.rx_search(name: query, howMany: 20).map {
                return $0.map {
                    return UserViewModel(user: $0)
                }
            }
        case .events:
            obs = EventsAPI.rx_search(name: query, howMany: 20).map {
                return $0.map {
                    return EventViewModel(event: $0)
                }
            }
        case .places:
            obs = PlacesAPI.rx_search(name: query, howMany: 20).map {
                return $0.map {
                    return PlaceViewModel(place: $0)
                }
            }
        }
        return obs
    }
}
