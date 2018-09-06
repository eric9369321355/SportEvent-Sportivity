//
//  UserHeaderTableViewCell.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 19/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserProfileHeaderTableViewCell: UITableViewCell, Configurable {

    @IBOutlet fileprivate weak var avatarImageVIew: UserAvatarImageView!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var followersLabel: UILabel!
    @IBOutlet weak var actionButton: ActionButton!
    
    /// Observable that informs that `Router` should route to the `Route`
    let onRouteTo : Observable<Route> = PublishSubject<Route>()
    
    var reuseBag = DisposeBag()
    
    var viewModel: UserProfileHeaderViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseBag = DisposeBag()
    }
    
    func configure(with viewModel: UserProfileHeaderViewModel) {
        viewModel
            .name
            .drive(nameLabel.rx.text)
            .addDisposableTo(reuseBag)
        
        viewModel
            .photoURL
            .driveNext { [unowned self] (url) in
                if let url = url {
                    self.avatarImageVIew.kf.setImage(with: url)
                } else {
                    self.avatarImageVIew.image = R.image.userPlaceholder()
                }
            }
            .addDisposableTo(reuseBag)
        
        viewModel
            .followers
            .drive(followersLabel.rx.text)
            .addDisposableTo(reuseBag)
        
        viewModel
            .isItMe
            .asDriver()
            .map { $0 ? "EDIT" : "FOLLOW" }
            .drive(actionButton.rx.title())
            .addDisposableTo(reuseBag)
        
        actionButton
            .rx.tap
            .asObservable()
            .subscribeNext { () in
                switch viewModel.isItMe.value {
                case true:
                    let route = Route(to: .editUser, type: nil, data: nil)
                    self.onRouteTo.asPublishSubject()!.onNext(route)
                case false:
                    print("follow")
                }
            }
            .addDisposableTo(reuseBag)
    }
}
