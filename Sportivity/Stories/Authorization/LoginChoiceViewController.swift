//
//  LoginChoiceViewController.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 17/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginChoiceViewController: UIViewController, ViewControllerProtocol, Configurable, ShowsError {

    /// Tag of the view
    let viewTag : ViewTag = .loginChoice
    /// Main `DisposeBag` of the `ViewController`
    let disposeBag = DisposeBag()
    /// Observable that informs that `Router` should route to the `Route`
    let onRouteTo : Observable<Route> = PublishSubject<Route>()
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet fileprivate weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    var viewModel: LoginChoiceViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //navigationController?.isNavigationBarHidden = true
    }
}

private extension LoginChoiceViewController {
    func bind() {
        email.rx.text <-> viewModel.email
        password.rx.text <-> viewModel.password
        
        loginButton
            .rx
            .tap
            .flatMap { [unowned self] () -> Observable<LoginResult> in
                return self.viewModel.login()
            }
            .subscribeNext { (result: LoginResult) in
                switch result {
                case .error(let message):
                    self.showQuickError(message: message)
                case .success:
                    let route = Route(to: .mainTab, type: nil)
                    self.onRouteTo.asPublishSubject()!.onNext(route)
                }
            }
            .addDisposableTo(disposeBag)
        
        signupButton
            .rx.tap
            .asObservable()
            .map { Route.init(to: .register, type: nil, data: nil) }
            .bind(to: onRouteTo.asPublishSubject()!)
            .addDisposableTo(disposeBag)
    }
}
