//
//  SearchViewController.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 19/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private struct SearchViewControllerConstants {
    static let tableTopInset = CGFloat(109)
}

private typealias C = SearchViewControllerConstants

class SearchViewController: UIViewController, ViewControllerProtocol, Configurable {

    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var searchBar: UISearchBar!
    
    @IBOutlet weak var usersButton: UIButton!
    @IBOutlet weak var eventsButton: UIButton!
    @IBOutlet weak var placesButton: UIButton!
    
    var viewModel: SearchViewModel! = SearchViewModel()
    
    /// Tag of the view
    let viewTag : ViewTag = .events
    /// Main `DisposeBag` of the `ViewController`
    let disposeBag = DisposeBag()
    /// Observable that informs that `Router` should route to the `Route`
    let onRouteTo : Observable<Route> = PublishSubject<Route>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsetsMake(C.tableTopInset, 0, 0, 0)
        tableView.register(R.nib.listingTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.listingTableCell.identifier)
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}



private extension SearchViewController {
    
    func bind() {
        searchBar
            .rx.text
            .asObservable()
            .debounce(0.3, scheduler: MainScheduler.instance)
            .bind(to: viewModel.searchQuery)
            .addDisposableTo(disposeBag)
        
        viewModel
            .data
            .asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: R.reuseIdentifier.listingTableCell.identifier, cellType: ListingTableViewCell.self)) {
                index, item, cell in
                cell.configure(with: item)
            }
            .addDisposableTo(disposeBag)
        
        usersButton.rx.tap.map { SearchType.users }.bind(to: viewModel.type).addDisposableTo(disposeBag)
        eventsButton.rx.tap.map { SearchType.events }.bind(to: viewModel.type).addDisposableTo(disposeBag)
        placesButton.rx.tap.map { SearchType.places }.bind(to: viewModel.type).addDisposableTo(disposeBag)
        
        viewModel
            .type
            .asObservable()
            .subscribeNext { [unowned self] (type) in
                self.usersButton.isSelected = type == .users
                self.eventsButton.isSelected = type == .events
                self.placesButton.isSelected = type == .places
            }
            .addDisposableTo(disposeBag)
        
        tableView
            .rx.modelSelected(ListingViewModelProtocol.self)
            .map { item -> Route in
                var route: Route!
                if let vm = item as? UserViewModel {
                    route = Route(to: .user, type: nil, data: vm)
                } else if let vm = item as? EventViewModel {
                    route = Route(to: .event, type: nil, data: vm)
                } else if let vm = item as? PlaceViewModel {
                    route = Route(to: .place, type: nil, data: vm.id)
                }
                return route
            }
            .bind(to: onRouteTo.asPublishSubject()!)
            .addDisposableTo(disposeBag)
        
        tableView
            .rx.itemSelected
            .asObservable()
            .subscribeNext { [unowned self] (indexPath) in
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            .addDisposableTo(disposeBag)
        
        viewModel
            .data
            .asObservable()
            .map { $0.count == 0 }
            .bind(to: tableView.rx.isHidden)
            .addDisposableTo(disposeBag)
    }
}
