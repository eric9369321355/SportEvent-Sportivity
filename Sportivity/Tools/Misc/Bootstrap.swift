//
//  Bootstrap.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 21/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import AlamofireNetworkActivityIndicator

class Bootstrap {
    static func bootstrap() {
        
        /// In order to make the activity indicator experience for a user as pleasant as possible,
        /// there need to be start and stop delays added in to avoid flickering
        NetworkActivityIndicatorManager.shared.startDelay = 0.5
        NetworkActivityIndicatorManager.shared.completionDelay = 0.5
        NetworkActivityIndicatorManager.shared.isEnabled = true
    }
}
