//
//  EventTableViewCell.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 07/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class EventTableViewCell: UITableViewCell, Configurable {
    
    static let deafultHeight: CGFloat = 200

    fileprivate var reuseBag = DisposeBag()

    @IBOutlet fileprivate weak var photoImageView: UIImageView!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var addressLabel: UILabel!
    @IBOutlet fileprivate weak var attendeesLabel: UILabel!
    @IBOutlet fileprivate weak var monthLabel: UILabel!
    @IBOutlet fileprivate weak var dayLabel: UILabel!

    var viewModel: EventViewModel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseBag = DisposeBag()
    }
    
    func configure() {
        viewModel
            .name
            .drive(nameLabel.rx.text)
            .addDisposableTo(reuseBag)
        viewModel
            .photoUrl
            .driveNext { [unowned self] (url) in
                self.photoImageView.kf.setImage(with: url)
            }
            .addDisposableTo(reuseBag)
        Observable
            .combineLatest(viewModel.address.asObservable(), viewModel.hour.asObservable(), viewModel.attendeesCount.asObservable()) { (address, hour, attendingCount) -> String in
                var text : String = address != nil ? address! : ""
                if text.isEmpty {
                    text = hour ?? ""
                } else if let hourText = hour, !hourText.isEmpty {
                    text += " • at \(hourText)"
                }
                guard let count = attendingCount, count > 0 else { return text }
                return "\(text) • \(count) attending"
            }
            .asDriver(onErrorJustReturn: "")
            .drive(addressLabel.rx.text)
            .addDisposableTo(reuseBag)
        viewModel
            .address
            .drive(addressLabel.rx.text)
            .addDisposableTo(reuseBag)
        viewModel
            .attendeesCount
            .map { count -> String? in
                guard let count = count, count > 0 else { return nil }
                return "\(count) attending"
            }
            .drive(attendeesLabel.rx.text)
            .addDisposableTo(reuseBag)
        viewModel
            .month
            .drive(monthLabel.rx.text)
            .addDisposableTo(reuseBag)
        viewModel
            .day
            .drive(dayLabel.rx.text)
            .addDisposableTo(reuseBag)
    }
}
