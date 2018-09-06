//
//  RxViewController.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 17/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// Base protocol for all ViewControllers used in Sportivity app
protocol ViewControllerProtocol {
    /// Tag of the view
    var viewTag : ViewTag { get }
    /// Main `DisposeBag` of the `ViewController`
    var disposeBag : DisposeBag { get }
    /// Observable that informs that `Router` should route to the `Route`
    var onRouteTo : Observable<Route> { get }
}
