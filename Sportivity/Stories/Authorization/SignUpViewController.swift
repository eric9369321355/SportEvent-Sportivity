//
//  SignUpViewController.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 07/06/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SignUpViewController: UIViewController, ViewControllerProtocol {

    /// Tag of the view
    let viewTag : ViewTag = .loginChoice
    /// Main `DisposeBag` of the `ViewController`
    let disposeBag = DisposeBag()
    /// Observable that informs that `Router` should route to the `Route`
    let onRouteTo : Observable<Route> = PublishSubject<Route>()
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signupButton: ActionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signupButton
            .rx.tap
            .asObservable()
            .flatMap { [unowned self] () -> Observable<Route> in
                return self.register()

                    .map { _ -> Route? in
                        return Route.init(to: .mainTab, type: nil, data: nil)
                    }
                    .catchErrorJustReturn(nil)
                    .filter { $0 != nil }
                    .map { $0! }
            }
            .bind(to: onRouteTo.asPublishSubject()!)
            .addDisposableTo(disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func register() -> Observable<Void> {
        guard let name = self.name.text, let email = self.email.text, let pass = self.password.text else {
            let error = APIError.request(RequestError.unknown)
            return Observable<Void>.error(error)
        }
        let obs = UserAPI
            .rx_create(name: name, email: email, pass: pass)
            .flatMap { (user) -> Observable<Void> in
                do {
                    try UserManager.shared.login(user: user)
                } catch let error {
                    return Observable.error(error)
                }
                return Observable.just()
        }
        return obs
    }
}
