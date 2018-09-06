//
//  QuadTree.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 18/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import MapKit

class QuadTree {
    
    let root: QuadTreeNode
    
    public init(rect: MKMapRect) {
        self.root = QuadTreeNode(rect: rect)
    }
    
    @discardableResult
    public func add(_ annotation: MKAnnotation) -> Bool {
        return root.add(annotation)
    }
    
    @discardableResult
    public func remove(_ annotation: MKAnnotation) -> Bool {
        return root.remove(annotation)
    }
    
    public func annotations(in rect: MKMapRect) -> [MKAnnotation] {
        return root.annotations(in: rect)
    }
    
}
