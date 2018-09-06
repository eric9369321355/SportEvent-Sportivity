//
//  ClusterAnnotationView.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 14/06/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import MapKit

struct ClusterAnnotationViewConstants {
    static let radius = 25.0
    static let outlineColor = UIColor.white
}

class ClusterAnnotationView: MKAnnotationView {
    
    typealias C = ClusterAnnotationViewConstants
    
    let color: UIColor
    
    let countLabel: UILabel
    
    override var annotation: MKAnnotation? {
        didSet {
            configure()
        }
    }
    
    public init(annotation: MKAnnotation?, reuseIdentifier: String?, color: UIColor = R.color.sportivity.sunsetOrange()) {
        self.color = color
        let label = UILabel()
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.backgroundColor = .clear
        label.font = .boldSystemFont(ofSize: 13)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 2
        label.baselineAdjustment = .alignCenters
        self.countLabel = label
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.addSubview(label)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        guard let annotation = annotation as? MapAnnotation else { return }
        
        switch annotation.type {
        case .cluster(let annotations):
            let count = annotations.count
            backgroundColor	= color
            var diameter = C.radius * 2
            if count < 8 {
                diameter *= 0.6
            } else if count < 16 {
                diameter *= 0.8
            }
            
            frame = CGRect(origin: frame.origin, size: CGSize(width: diameter, height: diameter))
            countLabel.text = String(count)
            
            layer.borderColor = C.outlineColor.cgColor
            layer.borderWidth = 2
        default:
            assert(false, "Wrong annotation type")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.masksToBounds = true
        layer.cornerRadius = image == nil ? bounds.width / 2 : 0
        countLabel.frame = bounds
    }
    
}
