//
//  Loc.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 25/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation
import Unbox

struct Loc {
    /// Coordinates in MongoDB format, i.e. a 2 element array of Longitude, Latitude, represented by float values.
    let coordinates: [Double]
    let lon: Double
    let lat: Double
    
    init(longitude: Double, latitude: Double) {
        // Note, backend operates on MongoDB format, i.e. [lon, lat]
        self.coordinates = [longitude, latitude]
        self.lon = longitude
        self.lat = latitude
    }
}

extension Loc: Unboxable {
    init(unboxer: Unboxer) throws {
        coordinates = try unboxer.unbox(key: "coordinates")
        lon = try unboxer.unbox(keyPath: "coordinates.0")
        lat = try unboxer.unbox(keyPath: "coordinates.1")
        // Fail mapping if geoLoc is a default back-end value
        if (lon == 0.0 && lat == 0.0) || (lon == 90.0  && lat == 0.0) || (lon == 0.0  && lat == 90.0) {
            throw UnboxError.invalidData
        }
    }
}
