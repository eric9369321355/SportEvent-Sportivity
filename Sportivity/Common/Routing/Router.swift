//
//  Router.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 17/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import RxSwift

enum ViewTag {
    case loginChoice
    case register

    case mainTab
    case events
//    case map
    
    case user
    case editUser
    case place
    case event
}

enum RouteType {
    case push
    case modal
    case tabSwitch
    case windowRootSwap
}

struct Route : CustomStringConvertible {
    let view : ViewTag
    let type : RouteType?
    /// Any data we want to pass, e.g. EventViewModel
    var data : Any?
    
    init(to view: ViewTag, type: RouteType? = nil, data : Any? = nil) {
        self.view = view
        self.type = type
        self.data = data
    }
    
    private func defaultType(for viewTag: ViewTag) -> RouteType {
        switch viewTag {
        case .loginChoice, .mainTab:
            return .windowRootSwap
        case .user, .event, .register, .place:
            return .push
        case .editUser:
            return .modal
        case .events:
            return .tabSwitch
        }
    }
    
    var description : String {
        return "Route(view: \(view))"
    }
}

class Router {
    
    // MARK: - Public properties
    
    let window : UIWindow
    
    // MARK: - Private properties
    
    fileprivate let userManager : UserManagerProtocol
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate var currentNavigationController : UINavigationController? = nil
    fileprivate var mainTabBarController : MainTabBarViewController? = nil {
        didSet {
            guard let mainTabBarController = self.mainTabBarController else { return }
            mainTabBarController
                .didSelect
                .subscribeNext { [unowned self] (viewController) in
                    guard let nvc = viewController as? UINavigationController else {
                        return
                    }
                    self.currentNavigationController = nvc
                }
                .addDisposableTo(disposeBag)
        }
    }
    
    // MARK: - Public methods
    
    init(window: UIWindow, userManager: UserManagerProtocol = UserManager.shared) {
        self.window = window
        self.userManager = userManager
        
        self.window.makeKeyAndVisible()
        
        self.userManager
            .rx_isLoggedIn
            .subscribeNext { [unowned self] (isLoggedIn) in
                Logger.shared.log(.info, className: "Router", message: "`isLoggedIn` change to \(isLoggedIn).")
                var route : Route!
                if isLoggedIn {
                    route = Route(to: .mainTab)
                } else {
                    route = Route(to: .loginChoice)
                }
                
                self.route(to: route)
            }
            .addDisposableTo(disposeBag)
    }
    
    @discardableResult
    func route(to destination: Route) -> UIViewController {
        Logger.shared.log(.info, className: "Router", message: "Routing to \(destination).")
        
        var destinationVC : UIViewController? = nil
        switch destination.view {
        case .loginChoice:
            let vc = R.storyboard.authorization.loginChoice()!
            vc.configure(with: LoginChoiceViewModel())
            let nvc = UINavigationController(rootViewController: vc)
            window.set(rootViewController: nvc)
            self.currentNavigationController = nvc
            destinationVC = vc
        case .register:
            let vc = R.storyboard.authorization.signup()!
            currentNavigationController?.pushViewController(vc, animated: true)
            destinationVC = vc
        case .mainTab:
            mainTabBarController = R.storyboard.mainTab.mainTab()!
            window.set(rootViewController: mainTabBarController!)
            destinationVC = mainTabBarController
        case .user:
            let vc = R.storyboard.user.user()!
            var vm: UserProfileViewModel!
            if let userData = destination.data as? UserRouteData {
                let maybeUser = userData as? User
                vm = UserProfileViewModel(id: userData.id, user: maybeUser)
            }
            vc.configure(with: vm)
            currentNavigationController?.pushViewController(vc, animated: true)
            destinationVC = vc
        case .editUser:
            let nvc = R.storyboard.user.editUserNavigation()!
            let vc = nvc.viewControllers.first! as! EditUserTableTableViewController
            currentNavigationController?.present(nvc, animated: true, completion: nil)
            destinationVC = vc
        case .event:
            let vc = R.storyboard.event.event()!
            let eventViewModel = destination.data as! EventViewModel
            let viewModel = EventProfileViewModel(event: eventViewModel.event)
            vc.configure(with: viewModel)
            currentNavigationController?.pushViewController(vc, animated: true)
            destinationVC = vc
        case .place:
            let vc = R.storyboard.place.place()!
            assert(destination.data != nil)
            assert(destination.data is String)
            let id: String = destination.data as! String
            let vm = PlaceProfileViewModel(id: id)
            vc.configure(with: vm)
            currentNavigationController?.pushViewController(vc, animated: true)
            destinationVC = vc
            
        // MAIN TAB SWITCHES
        case .events:
            // HACK: this is not supported and we just return UITabViewController because we need to return something.
            return mainTabBarController!
        }
        
        assert(destinationVC != nil, "destinationVC cannot be nil")
        guard let destinationVcProtocol = destinationVC as? ViewControllerProtocol else {
            return UIViewController()
            //fatalError("destinationVC does not conform to ViewControllerProtocol")
        }
        
        destinationVcProtocol
            .onRouteTo
            .subscribeNext({ [unowned self] (route) in
                self.route(to: route)
            })
            .addDisposableTo(disposeBag)
        
        return destinationVC!
    }
}
