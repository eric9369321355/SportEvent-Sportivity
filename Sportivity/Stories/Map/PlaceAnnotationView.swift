//
//  PlaceAnnotationView.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 11/06/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import MapKit

struct PlaceAnnotationViewConstants {
    static let radius = 15.0
}

private typealias C = PlaceAnnotationViewConstants

class PlaceAnnotationView: MKAnnotationView {

    fileprivate let imageView = UIImageView()
    
    override open var annotation: MKAnnotation? {
        didSet {
            configure()
        }
    }
    
    public init(annotation: MKAnnotation?, reuseIdentifier: String?, color: UIColor = R.color.sportivity.sunsetOrange()) {
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.cornerRadius = CGFloat(C.radius)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill

        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        layer.cornerRadius = CGFloat(C.radius)
        layer.borderColor = color.cgColor
        layer.borderWidth = 4
        
        backgroundColor = color
        let imageFrame = CGRect(origin: frame.origin, size: CGSize(width: 2*C.radius - 4, height: 2*C.radius - 4))
        imageView.frame = imageFrame
        imageView.center = self.center
        self.addSubview(imageView)
        
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private func configure() {
        guard let annotation = annotation as? MapAnnotation else { return }
        
        switch annotation.type {
        case .place(_, let category, _):
            self.imageView.image = category?.iconImage
        default:
            assert(false, "Wrong annotation type")
        }
    }
}
