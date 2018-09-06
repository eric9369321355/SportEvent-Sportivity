//
//  AvatarView.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 19/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

fileprivate struct AvatarImageViewConstants {
    static var placeholder : UIImage {
        return R.image.football()!
    }
    
    static let borderWidth = CGFloat(0)
    static let borderColor = UIColor.clear
}

fileprivate typealias C = AvatarImageViewConstants

class AvatarImageView: UIImageView {
    ///NOTE: Enable user interaction in IB for this to work.
    let rx_tap: Observable<Void> = PublishSubject<Void>()
    fileprivate let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
        image = C.placeholder
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
        image = C.placeholder
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        config()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.bounds.width / CGFloat(2)
    }
    
    fileprivate func config() {
        contentMode = .scaleAspectFill
        backgroundColor = UIColor.white
        clipsToBounds = true
        layer.borderColor = C.borderColor.cgColor
        layer.borderWidth = C.borderWidth
        let tap = UITapGestureRecognizer(target: self, action: nil)
        tap
            .rx.event
            .asObservable()
            .map { _ in
                return Void()
            }
            .bind(to: rx_tap.asPublishSubject()!)
            .addDisposableTo(disposeBag)
        self.addGestureRecognizer(tap)
    }
}
