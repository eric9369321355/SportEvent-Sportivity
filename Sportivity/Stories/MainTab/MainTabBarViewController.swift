//
//  MainTabBarViewController.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 18/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private struct MainTabBarViewControllerConstants {
    
}

class MainTabBarViewController: UITabBarController, ViewControllerProtocol {

    // VIEW CONTROLLER PROTOCOL
    
    /// Tag of the view
    let viewTag : ViewTag = .mainTab
    /// Main `DisposeBag` of the `ViewController`
    let disposeBag = DisposeBag()
    /// Observable that informs that `Router` should route to the `Route`
    let onRouteTo : Observable<Route> = PublishSubject<Route>()
    
    // PUBLIC
    
    let didSelect: Observable<UIViewController> = PublishSubject<UIViewController>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewControllers = self.viewControllers else {
            assert(false)
            return
        }

        for nvc in viewControllers {
            guard let nvc = nvc as? UINavigationController, let vcProtocol = nvc.childViewControllers.first as? ViewControllerProtocol else {
                continue
            }
            vcProtocol
                .onRouteTo
                .bind(to: onRouteTo.asPublishSubject()!)
                .addDisposableTo(disposeBag)
        }
        
        self.delegate = self
        if let first = self.viewControllers?.first {
            self.didSelect.asPublishSubject()!.onNext(first)
        }
    }
}

extension MainTabBarViewController : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let nvc = viewController as? UINavigationController, let vc = nvc.childViewControllers.first as? UserProfileViewController, vc.viewModel == nil {
            let user = UserManager.shared.user!
            let vm = UserProfileViewModel(id: user.id, user: user)
            vc.configure(with: vm)
        }
        
        self.didSelect.asPublishSubject()!.onNext(viewController)
    }
}
