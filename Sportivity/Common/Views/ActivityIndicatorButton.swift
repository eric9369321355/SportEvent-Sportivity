//
//  ActivityIndicatorButton.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 19/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit

private struct ActivityIndicatorButtonConstants {
    static let xMargin : CGFloat = 25
}

class ActivityIndicatorButton: UIButton {
    
    private typealias C = ActivityIndicatorButtonConstants
    var indicator : UIActivityIndicatorView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let indicator = indicator {
            self.adjustPosition(indicator)
        }
    }
    
    func adjustPosition(_ view: UIView) {
        let x = self.titleLabel!.frame.origin.x + (self.titleLabel?.frame.width)! + C.xMargin
        view.center = CGPoint(x: x , y: self.frame.size.height/2.0)
        
    }
    
    func showIndicator() {
        self.removeIndicator()
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        if let indicator = indicator {
            indicator.startAnimating()
            self.addSubview(indicator)
        }
    }
    
    func removeIndicator() {
        indicator?.removeFromSuperview()
        indicator = nil
    }
}
