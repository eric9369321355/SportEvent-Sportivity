//
//  UserAvatarImageView.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 19/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit


fileprivate struct UserAvatarImageViewConstants {
    static var placeholder : UIImage {
        return R.image.userPlaceholder()!
    }
}

private typealias C = UserAvatarImageViewConstants

class UserAvatarImageView: AvatarImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        image = C.placeholder
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        image = C.placeholder
    }
}
