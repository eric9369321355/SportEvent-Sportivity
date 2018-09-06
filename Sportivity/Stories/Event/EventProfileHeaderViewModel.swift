//
//  EventProfileHeaderViewModel.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 25/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class EventProfileHeaderViewModel {
    
    fileprivate static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d', ' HH:mm"
        return formatter
    }()
    fileprivate static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    fileprivate let event: Event
    fileprivate let userManager: UserManagerProtocol
    fileprivate let disposeBag = DisposeBag()
    
    let id: String
    let name: Driver<String>
    let photoUrl: Driver<URL?>
    let date: Driver<String?>
    let hostText: Driver<String>
    let placeName: Driver<String?>
    let placeLoc: Driver<Loc?>
    let street: Driver<String?>
    let city: Driver<String?>
    let attendees: Variable<[EventAttendee]>
    let isAttending = Variable<Bool>(false)
    let capacity: Driver<Int?>
    let attendingCount: Driver<Int>
    
    let toggleAttend = PublishSubject<Void>()
    
    var placeId: String? {
        return event.place.value?.id
    }
    
    init(event: Event, userManager: UserManagerProtocol = UserManager()) {
        self.event = event
        self.id = event.id
        self.userManager = userManager
        
        self.name = self.event.name.asDriver()
        let placePhoto = event.place.asDriver().flatMap { (place) -> Driver<URL?> in
            guard let place = place else {
                return Driver<URL?>.just(nil)
            }
            return place.photoURL.asDriver()
        }
        let eventPhoto = self.event.photoUrl.asDriver()
        photoUrl = Driver.combineLatest(eventPhoto, placePhoto, resultSelector: { (eventPhoto, placePhoto) in
            return eventPhoto ?? placePhoto
        })
        date = Observable
            .combineLatest(self.event.dateStart.asObservable(), self.event.dateEnd.asObservable(), resultSelector: { (start, end) -> String? in
                var text = EventProfileHeaderViewModel.dateFormatter.string(from: start)
                if let end = end {
                    text += (" – " + EventProfileHeaderViewModel.hourFormatter.string(from: end))
                }
                return text
            })
            .asDriver(onErrorJustReturn: nil)
        let hostText: Observable<String> = event.host.asObservable()
            .flatMap({ (user) -> Observable<String> in
                guard let user = user else { return Observable.just("") }
                return user.name.asObservable()
            })
            .map { (name) -> String in
                return "Organised by: \(name)"
            }
        self.placeName = event.place.asDriver().map { $0?.name.value }
        self.placeLoc = event.place.asDriver().map { $0?.loc.value }
        self.street = event.place.asDriver().map { $0?.street.value }
        self.city = event.place.asDriver().map { $0?.city.value }
        self.hostText = hostText.asDriver(onErrorJustReturn: "")
        self.capacity = event.capacity.asDriver()
        self.attendees = event.attendees
        self.attendingCount = event.attendees.asDriver().map { $0.count }

        attendees
            .asObservable()
            .map { [unowned self] attendees -> Bool in
                guard let myId = self.userManager.user?.id else { return false }
                let isAttending = attendees.reduce(false, { (isAttending, attendee) -> Bool in
                    return isAttending || attendee.id == myId
                })
                return isAttending
            }
            .bind(to: isAttending)
            .addDisposableTo(disposeBag)
        
        bind()
    }
    
    private func bind() {
        toggleAttend
            .withLatestFrom(isAttending.asObservable())
            .doOnNext { (isAttending) in
                Logger.shared.log(.info, message: "toggleAttend from isAttending=\(isAttending) to \(!isAttending)")
            }
            .flatMap { [unowned self] (isAttending) -> Observable<Bool?> in
                if isAttending {
                    return EventsAPI.rx_leave(self.event.id).map { false }.catchErrorJustReturn(nil)
                } else {
                    return EventsAPI.rx_join(self.event.id).map { true }.catchErrorJustReturn(nil)
                }
            }
            .subscribeNext { [unowned self] (isAttending) in
                guard let isAttending = isAttending else {
                    return
                }
                guard let me = self.userManager.user else {
                    assert(false)
                    return
                }
                if isAttending {
                    let meAttendee = EventAttendee(user: me)
                    var newAttendees = self.attendees.value
                    newAttendees.append(meAttendee)
                    self.event.attendees.value = newAttendees
                } else {
                    let newAttendees = self.attendees.value.filter { $0.id != me.id }
                    self.event.attendees.value = newAttendees
                }
            }
            .addDisposableTo(disposeBag)
        
    }
}
