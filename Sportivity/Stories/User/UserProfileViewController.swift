//
//  UserViewController.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 19/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserProfileViewController: UIViewController, ViewControllerProtocol, Configurable, ShowsError {
    
    /// Tag of the view
    let viewTag : ViewTag = .user
    /// Main `DisposeBag` of the `ViewController`
    let disposeBag = DisposeBag()
    /// Observable that informs that `Router` should route to the `Route`
    let onRouteTo : Observable<Route> = PublishSubject<Route>()

    @IBOutlet fileprivate weak var tableView: UITableView!
    fileprivate var logoutBarButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    
    var viewModel: UserProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Profile"
        tableView.register(R.nib.eventTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.eventTableViewCell.identifier)
        tableView.rx.setDelegate(self).addDisposableTo(disposeBag)
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

private extension UserProfileViewController {
    func bind() {
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            let title = "Pull to refresh"
            refreshControl.attributedTitle = NSAttributedString(string: title)
            refreshControl
                .rx.controlEvent(UIControlEvents.allEvents)
                .flatMap({ [unowned self] () -> Observable<UserProfileViewModelFetchResult> in
                    return self.viewModel.refresh()
                })
                .subscribeNext({ [unowned self] (result) in
                    self.tableView.refreshControl?.endRefreshing()
                    switch result {
                    case .error(let message):
                        self.showQuickError(message: message)
                    default:
                        break
                    }
                })
                .addDisposableTo(disposeBag)
            tableView.refreshControl = refreshControl
        }
        
        viewModel
            .cellsData
            .asDriver()
            .drive(tableView.rx.items) {
                tableView, row, item in
                let indexPath = IndexPath(item: row, section: 0)
                
                var cell: UITableViewCell!
                switch item {
                case let vm as UserProfileHeaderViewModel:
                    let reuseId = R.reuseIdentifier.userHeaderTableCell.identifier
                    cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
                    let cell = cell as! UserProfileHeaderTableViewCell
                    cell.configure(with: vm)
                    cell.onRouteTo.bind(to: self.onRouteTo.asPublishSubject()!).addDisposableTo(cell.reuseBag)
                case let vm as EventViewModel:
                    let reuseId = R.reuseIdentifier.eventTableViewCell
                    cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
                    let cell = cell as! EventTableViewCell
                    cell.configure(with: vm)
                default:
                    assert(false)
                    break
                }
                return cell
            }
            .addDisposableTo(disposeBag)
        
        tableView
            .rx.itemSelected
            .asObservable()
            .subscribeNext { [unowned self] (indexPath) in
                self.tableView.deselectRow(at: indexPath, animated: true)
                let item = self.viewModel.cellsData.value[indexPath.item]
                if let event = item as? EventViewModel {
                    let route = Route(to: .event, type: nil, data: event)
                    self.onRouteTo.asPublishSubject()!.onNext(route)
                }
            }
            .addDisposableTo(disposeBag)
        
        logoutBarButton
            .rx.tap
            .asObservable()
            .subscribeNext { [unowned self] () in
                self.viewModel.logout()
            }
            .addDisposableTo(disposeBag)
        
        viewModel
            .isItMe.asObservable()
            .subscribeNext { [unowned self] (isMe) in
                if isMe {
                    self.navigationItem.rightBarButtonItem = self.logoutBarButton
                } else {
                    self.navigationItem.rightBarButtonItem = nil
                }
            }
            .addDisposableTo(disposeBag)
    }
}

extension UserProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 284.5
        default:
            return EventTableViewCell.deafultHeight
        }
    }
}
