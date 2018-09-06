//
//  PlacePinAnnotationView.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 09/07/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import MapKit
import RxSwift

class PlacePinAnnotationView: MKPinAnnotationView {
    var reuseBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseBag = DisposeBag()
    }
}
