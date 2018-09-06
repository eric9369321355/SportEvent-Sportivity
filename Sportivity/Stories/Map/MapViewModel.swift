//
//  MapViewModel.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 08/06/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit

class MapViewModel {
    
    let placeAnnotations = Variable<[MapAnnotation]>([ ])
    let disposeBag = DisposeBag()
    
    init() {
        fetch()
    }
    
    private func fetch() {
        PlacesAPI
            .rx_fetchAll()
            .catchErrorJustReturn([])
            .map({ (places) -> [MapAnnotation] in
                
                return places.map { place in
                    let type = MapAnnotationType.place(id: place.id,category: place.sportCategories.value.first, photoUrl: place.photoURL.value)
                    let annotation = MapAnnotation(type: type)
                    annotation.title = place.name.value
                    if let lat = place.loc.value?.lat, let lon = place.loc.value?.lon {
                        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    }
                    return annotation
                }
            })
            .bind(to: placeAnnotations)
            .addDisposableTo(disposeBag)
    }
}
