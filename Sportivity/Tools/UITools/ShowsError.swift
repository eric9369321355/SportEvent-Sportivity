//
//  ShowsError.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 22/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import Whisper

protocol ShowsError { }

extension ShowsError {
    func showQuickError(message: String) {
        let murmur = Murmur(title: message, backgroundColor: R.color.sportivity.vividTangerine(), titleColor: UIColor.white, font: UIFont.systemFont(ofSize: 12), action: nil)
        Whisper.show(whistle: murmur, action: WhistleAction.show(2))
    }
}
