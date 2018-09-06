//
//  Tools.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 20/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import MapKit


let CLLocationCoordinate2DMax = CLLocationCoordinate2D(latitude: 90, longitude: 180)
let MKMapPointMax = MKMapPointForCoordinate(CLLocationCoordinate2DMax)

extension CLLocationCoordinate2D: Hashable, Equatable {
    public var hashValue: Int {
        return latitude.hashValue ^ longitude.hashValue
    }
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}


extension MKMapRect {
    var minX: Double {
        return MKMapRectGetMinX(self)
    }
    var minY: Double {
        return MKMapRectGetMinY(self)
    }
    var midX: Double {
        return MKMapRectGetMidX(self)
    }
    var midY: Double {
        return MKMapRectGetMidY(self)
    }
    var maxX: Double {
        return MKMapRectGetMaxX(self)
    }
    var maxY: Double {
        return MKMapRectGetMaxY(self)
    }
    
    init(minX: Double, minY: Double, maxX: Double, maxY: Double) {
        self.init(x: minX, y: minY, width: abs(maxX - minX), height: abs(maxY - minY))
    }
    init(x: Double, y: Double, width: Double, height: Double) {
        self.init(origin: MKMapPoint(x: x, y: y), size: MKMapSize(width: width, height: height))
    }
}
