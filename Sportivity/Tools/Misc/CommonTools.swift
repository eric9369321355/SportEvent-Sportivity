//
//  CommonTools.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 10/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import MapKit
import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}


typealias ZoomScale = Double
extension ZoomScale {
    func zoomLevel() -> Double {
        let totalTilesAtMaxZoom = MKMapSizeWorld.width / 256
        let zoomLevelAtMaxZoom = log2(totalTilesAtMaxZoom)
        return max(0, zoomLevelAtMaxZoom + floor(log2(self) + 0.5))
    }
    func cellSize() -> Double {
        switch self {
        case 13...15:
            return 64
        case 16...18:
            return 32
        case 19 ..< .greatestFiniteMagnitude:
            return 16
        default: // Less than 13
            return 88
        }
    }
}

extension MKMapRect {
    func intersects(_ rect: MKMapRect) -> Bool {
        return MKMapRectIntersectsRect(self, rect)
    }
    
    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return MKMapRectContainsPoint(self, MKMapPointForCoordinate(coordinate))
    }
}
