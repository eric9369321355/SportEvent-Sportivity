//
//  RxTools.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 18/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

infix operator <->

@discardableResult func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    let bindToUIDisposable = variable
        .asObservable()
        .bind(to: property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            variable.value = n
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })
    
    return CompositeDisposable(bindToUIDisposable, bindToVariable)
}

/// Extensions providing backwords compatibility to older version of RxSwift
extension ObservableType {
    /**
     Subscribes an element handler to an observable sequence.
     
     - parameter onNext: Action to invoke for each element in the observable sequence.
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
    public func subscribeNext(_ onNext: @escaping (E) -> Void) -> Disposable {
        return subscribe(onNext: onNext, onError: nil, onCompleted: nil, onDisposed: nil)
    }
    
    /**
     Subscribes a completion handler to an observable sequence.
     
     - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
    public func subscribeCompleted(_ onCompleted: @escaping () -> Void) -> Disposable {
        return subscribe(onNext: nil, onError: nil, onCompleted: onCompleted, onDisposed: nil)
    }
    
    /**
     Subscribes an error handler to an observable sequence.
     
     - parameter onError: Action to invoke upon errored termination of the observable sequence.
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
    public func subscribeError(_ onError: @escaping (Error) -> Void) -> Disposable {
        return subscribe(onNext: nil, onError: onError, onCompleted: nil, onDisposed: nil)
    }
    
    /**
     Invokes an action for the Error event in the observable sequence, and propagates all observer messages through the result sequence.
     
     - parameter onError: Action to invoke upon errored termination of the observable sequence.
     - returns: The source sequence with the side-effecting behavior applied.
     */
    public func doOnError(_ onError: @escaping (Error) throws -> Void) -> Observable<E> {
        return self.do(onNext: nil, onError: onError, onCompleted: nil, onSubscribe: nil, onDispose: nil)
    }
    
    /**
     Invokes an action for each Next event in the observable sequence, and propagates all observer messages through the result sequence.
     
     - parameter onNext: Action to invoke for each element in the observable sequence.
     - returns: The source sequence with the side-effecting behavior applied.
     */
    public func doOnNext(onNext: @escaping ((E) throws -> Void)) -> Observable<E> {
        return self.do(onNext: onNext, onError: nil, onCompleted: nil, onSubscribe: nil, onDispose: nil)
    }
}

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy {
    
    /**
     Subscribes an element handler, a completion handler and disposed handler to an observable sequence.
     This method can be only called from `MainThread`.
     
     Error callback is not exposed because `Driver` can't error out.
     
     - parameter onNext: Action to invoke for each element in the observable sequence.
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
    public func driveNext(onNext: @escaping ((E) -> Void)) -> Disposable {
        return self.drive(onNext: onNext, onCompleted: nil, onDisposed: nil)
    }
}

extension Observable {
    
    func asPublishSubject() -> PublishSubject<Element>? {
        return self as? PublishSubject<Element>
    }
    
    func asBehaviorSubject() -> BehaviorSubject<Element>? {
        return self as? BehaviorSubject<Element>
    }
}
