
//
//  EventViewModel.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 18/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift
import RxCocoa

class EventViewModel : IdentifiableType, Equatable {
    
    fileprivate static var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    fileprivate static var monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()
    
    fileprivate static var hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        return formatter
    }()
    
    let event: Event
    
    typealias Identity = String
    let identityID: String = UUID().uuidString
    var identity: String {
        return identityID
    }
    
    let name: Driver<String>
    let photoUrl: Driver<URL?>
    let address: Driver<String?>
    let attendeesCount: Driver<Int?>
    let month: Driver<String?>
    let day: Driver<String?>
    let hour: Driver<String?>
    
    let category: Variable<Category?>

    init(event: Event) {
        self.event = event
        name = event.name.asDriver()
        let placePhoto = event.place.asDriver().flatMap { (place) -> Driver<URL?> in
            guard let place = place else {
                return Driver<URL?>.just(nil)
            }
            return place.photoURL.asDriver()
        }
        let eventPhoto = event.photoUrl.asDriver()
        photoUrl = Driver.combineLatest(eventPhoto, placePhoto, resultSelector: { (eventPhoto, placePhoto) in
            return eventPhoto ?? placePhoto
        })
        address = event.place
            .asObservable()
            .flatMap { (place) -> Observable<String?> in
                return place?.street.asObservable() ?? Observable<String?>.just(nil)
            }
            .asDriver(onErrorJustReturn: nil)
        attendeesCount = event.attendees.asDriver().map { $0.count }
        month = event.dateStart.asDriver().map({ (date) -> String? in
            return EventViewModel.monthFormatter.string(from: date).uppercased()
        })
        day = event.dateStart.asDriver().map({ (date) -> String? in
            return EventViewModel.dayFormatter.string(from: date).uppercased()
        })
        hour = event.dateStart.asDriver().map({ (date) -> String? in
            return EventViewModel.hourFormatter.string(from: date)
        })
        category = event.sportCategory
    }
}
