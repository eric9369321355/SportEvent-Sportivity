//
//  ActionButton.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 19/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit

class ActionButton : ActivityIndicatorButton {
    
    var startColor: UIColor = R.color.sportivity.vividTangerine() {
        didSet{
            setupView()
        }
    }
    
    var endColor: UIColor = R.color.sportivity.mellowYellow() {
        didSet{
            setupView()
        }
    }
    
    @IBInspectable var isHorizontal: Bool = true {
        didSet{
            setupView()
        }
    }
    
    override class var layerClass:AnyClass{
        return CAGradientLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    fileprivate func setupView(){
        tintColor = UIColor.white
        
        
        let colors:Array<AnyObject> = [startColor.cgColor, endColor.cgColor]
        gradientLayer.colors = colors
        gradientLayer.cornerRadius = CGFloat(self.bounds.height / 2.0)
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        
        if (isHorizontal){
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        }else{
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        }
        
        self.setNeedsDisplay()
    }
    
    // Helper to return the main layer as CAGradientLayer
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
}
