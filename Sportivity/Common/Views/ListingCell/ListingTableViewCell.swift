//
//  ListingTableViewCell.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 19/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import RxSwift

class ListingTableViewCell: UITableViewCell, Configurable {
    
    @IBOutlet fileprivate weak var avatarImageView: AvatarImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    var viewModel: ListingViewModelProtocol!
    
    fileprivate var reuseBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseBag = DisposeBag()
    }
    
    func configure() {
        viewModel
            .title
            .drive(titleLabel.rx.text)
            .addDisposableTo(reuseBag)
        
        viewModel
            .imageUrl
            .driveNext { [unowned self] (url) in
                if let url = url {
                    self.avatarImageView.kf.setImage(with: url)
                } else if self.viewModel is UserViewModel {
                    self.avatarImageView.image = R.image.userPlaceholder()
                }
            }
            .addDisposableTo(reuseBag)
    }
}
