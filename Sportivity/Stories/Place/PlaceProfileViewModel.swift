//
//  PlaceProfileViewModel.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 09/07/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PlaceProfileViewModel {
    
    fileprivate let id: String
    let cellsData = Variable<[Any]>([ ])
    
    fileprivate let disposeBag = DisposeBag()
    
    init(id: String) {
        self.id = id
        refresh()
    }
    
    func refresh() {
        fetchPlace()
            .subscribeNext { [unowned self] place in
                self.configure(with: place)
            }
            .addDisposableTo(disposeBag)
    }
}

private extension PlaceProfileViewModel {
    func fetchPlace() -> Observable<Place> {
        return PlacesAPI.rx_fetchPlace(id: id)
    }
    
    func configure(with place: Place) {
        var cells = [Any]()
        let header = PlaceProfileHeaderViewModel(place: place)
        cells.append(header)
        for event in place.events.value {
            cells.append(EventViewModel(event: event))
        }
        cellsData.value = cells
    }
}
