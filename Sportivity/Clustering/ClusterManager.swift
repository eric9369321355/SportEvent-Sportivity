//
//  ClusterManager.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 18/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import CoreLocation
import MapKit

class ClusterManager {
    let queue: OperationQueue

    var tree = QuadTree(rect: MKMapRectWorld)
    var annotations: [MKAnnotation] {
        return tree.annotations(in: MKMapRectWorld)
    }
    
    var zoomLevel: Int = 20 {
        didSet {
            zoomLevel = zoomLevel.clamped(to: 2...20)
        }
    }
    
    public init() {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
        self.queue = queue
    }
    
    func removeAll() {
        tree = QuadTree(rect: MKMapRectWorld)
    }
    
    func remove(_ annotations: [MKAnnotation]) {
        for annotation in annotations {
            remove(annotation)
        }
    }
    
    func remove(_ annotation: MKAnnotation) {
        tree.remove(annotation)
    }

    func add(_ annotation: MKAnnotation) {
        tree.add(annotation)
    }
    
    func add(_ annotations: [MKAnnotation]) {
        for annotation in annotations {
            add(annotation)
        }
    }
    
    func mapViewChanged(_ mapView: MKMapView, visibleMapRect: MKMapRect) {
        let dateStart = Date()
        
        let operation = BlockOperation()
        
        operation.addExecutionBlock { [weak self, weak mapView] in
            guard
                let `self` = self,
                let mapView = mapView
                else {
                    return
            }
            
            let zoomScale = ZoomScale(mapView.bounds.width) / visibleMapRect.size.width
            guard zoomScale.isInfinite == false else {
                return
            }
            
            let zoomLevel = zoomScale.zoomLevel()
            let cellSize = zoomLevel.cellSize()
            let scaleFactor = zoomScale / cellSize
            
            let minX = Int(floor(visibleMapRect.minX * scaleFactor))
            let maxX = Int(floor(visibleMapRect.maxX * scaleFactor))
            let minY = Int(floor(visibleMapRect.minY * scaleFactor))
            let maxY = Int(floor(visibleMapRect.maxY * scaleFactor))
            
            var clusteredAnnotations = [MKAnnotation]()
            
            for x in minX...maxX where !operation.isCancelled {
                for y in minY...maxY where !operation.isCancelled {
                    var mapRect = MKMapRect(x: Double(x) / scaleFactor, y: Double(y) / scaleFactor, width: 1 / scaleFactor, height: 1 / scaleFactor)
                    if mapRect.origin.x > MKMapPointMax.x {
                        mapRect.origin.x -= MKMapPointMax.x
                    }
                    
                    var totalLatitude: Double = 0
                    var totalLongitude: Double = 0
                    var annotations = [MKAnnotation]()
                    
                    for node in self.tree.annotations(in: mapRect) {
                        totalLatitude += node.coordinate.latitude
                        totalLongitude += node.coordinate.longitude
                        annotations.append(node)
                    }
                    
                    let count = annotations.count
                    if count > 1, Int(zoomLevel) <= self.zoomLevel {
                        let coordinate = CLLocationCoordinate2D(
                            latitude: CLLocationDegrees(totalLatitude) / CLLocationDegrees(count),
                            longitude: CLLocationDegrees(totalLongitude) / CLLocationDegrees(count)
                        )
                        let cluster = MapAnnotation(type: MapAnnotationType.cluster(annotations: annotations))
                        cluster.coordinate = coordinate
                        clusteredAnnotations.append(cluster)
                    } else {
                        clusteredAnnotations += annotations
                    }
                }
            }
            
            if operation.isCancelled {
                return
            }
            
            let before = NSMutableSet(array: mapView.annotations)
            before.remove(mapView.userLocation)
            let after = NSSet(array: clusteredAnnotations)
            let toKeep = NSMutableSet(set: before)
            toKeep.intersect(after as Set<NSObject>)
            let toAdd = NSMutableSet(set: after)
            toAdd.minus(toKeep as Set<NSObject>)
            let toRemove = NSMutableSet(set: before)
            toRemove.minus(after as Set<NSObject>)
            
            if !operation.isCancelled {
                DispatchQueue.main.async { [weak mapView] in
                    guard let mapView = mapView else { return }
                    let toAdd = toAdd.allObjects as? [MKAnnotation] ?? [MKAnnotation]()
                    let toRemove = toRemove.allObjects as? [MKAnnotation] ?? [MKAnnotation]()
                    mapView.removeAnnotations(toRemove)
                    mapView.addAnnotations(toAdd)
                    
                    let dateStop = Date()
                    let timeInSeconds = dateStop.timeIntervalSince(dateStart)
                    let zoomScale = ZoomScale(mapView.bounds.width) / visibleMapRect.size.width
                    Logger.shared.log(.info, className: "ClusterManager", message: "[Algorithm] - Clustering took \(timeInSeconds) sec. for zoomScale = \(zoomScale)")
                }
            }
        }
        
        queue.cancelAllOperations()
        queue.addOperation(operation)
    }
}
