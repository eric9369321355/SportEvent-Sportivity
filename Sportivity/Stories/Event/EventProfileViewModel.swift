//
//  EventProfileViewModel.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 24/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class EventProfileViewModel {
    
    fileprivate let event: Event
    let cellsData = Variable<[Any]>([ ])
    
    fileprivate let disposeBag = DisposeBag()
    
    init(event: Event) {
        self.event = event
        buildCellViewModels()
        self.event.attendees.asObservable().subscribeNext { [unowned self] (_) in
            self.buildCellViewModels()
        }.addDisposableTo(disposeBag)
    }
    
    private func buildCellViewModels() {
        var arr = [Any]()
        let header = EventProfileHeaderViewModel(event: self.event)
        arr.append(header)
        for attendee in event.attendees.value {
            let user = UserViewModel(attendee: attendee)
            arr.append(user)
        }
        self.cellsData.value = arr
    }
}
