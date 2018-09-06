//
//  QuadTreeNode.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 18/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import MapKit

struct QuadTreeNodeConstants {
    static let bucketCapacity = 8
}

private typealias C = QuadTreeNodeConstants

class QuadTreeNode {
    
    var annotations = [MKAnnotation]()
    let rect: MKMapRect
    var type: QuadTreeNodeType = .leaf
    
    init(rect: MKMapRect) {
        self.rect = rect
    }
    
    // MARK: - Public methods
    
    @discardableResult
    func add(_ annotation: MKAnnotation) -> Bool {
        guard rect.contains(annotation.coordinate) else { return false }
        
        switch type {
        case .leaf:
            annotations.append(annotation)
            if annotations.count == C.bucketCapacity {
                subdivide()
            }
        case .cluster(let children):
            for child in children where child.add(annotation) {
                return true
            }
            
            fatalError("none of child nodes added the annotation")
        }
        return true
    }
    
    @discardableResult
    func remove(_ annotation: MKAnnotation) -> Bool {
        guard rect.contains(annotation.coordinate) else { return false }
        
        _ = annotations.map { $0.coordinate }.index(of: annotation.coordinate).map { annotations.remove(at: $0) }
        switch type {
        case .leaf: break
        case .cluster(let children):
            for child in children where child.remove(annotation) {
                return true
            }
            
            fatalError("none of child nodes removed the annotation")
        }
        return true
    }
    
    func annotations(in rect: MKMapRect) -> [MKAnnotation] {
        guard self.rect.intersects(rect) else { return [] }
        
        var result = [MKAnnotation]()
        for annotation in annotations where rect.contains(annotation.coordinate) {
            result.append(annotation)
        }
        
        switch type {
        case .leaf: break
        case .cluster(let children):
            for childNode in children {
                result.append(contentsOf: childNode.annotations(in: rect))
            }
        }
        
        return result
    }
    
}

private extension QuadTreeNode {
    func subdivide() {
        switch type {
        case .leaf:
            type = .cluster(children: QuadTreeNodeChildren(parentNode: self))
        case .cluster:
            fatalError("This node is already divided")
        }
    }
}


struct QuadTreeNodeChildren: Sequence {
    let nw: QuadTreeNode
    let ne: QuadTreeNode
    let sw: QuadTreeNode
    let se: QuadTreeNode
    
    init(parentNode: QuadTreeNode) {
        let mapRect = parentNode.rect
        nw = QuadTreeNode(rect: MKMapRect(minX: mapRect.minX, minY: mapRect.minY, maxX: mapRect.midX, maxY: mapRect.midY))
        ne = QuadTreeNode(rect: MKMapRect(minX: mapRect.midX, minY: mapRect.minY, maxX: mapRect.maxX, maxY: mapRect.midY))
        sw = QuadTreeNode(rect: MKMapRect(minX: mapRect.minX, minY: mapRect.midY, maxX: mapRect.midX, maxY: mapRect.maxY))
        se = QuadTreeNode(rect: MKMapRect(minX: mapRect.midX, minY: mapRect.midY, maxX: mapRect.maxX, maxY: mapRect.maxY))
    }
    
    public func makeIterator() -> QuadTreeNodeChildrenIterator {
        return QuadTreeNodeChildrenIterator(children: self)
    }
}

struct QuadTreeNodeChildrenIterator: IteratorProtocol {
    private var index = 0
    private let children: QuadTreeNodeChildren
    
    init(children: QuadTreeNodeChildren) {
        self.children = children
    }
    
    mutating func next() -> QuadTreeNode? {
        switch index {
        case 0:
            index += 1
            return children.nw
        case 1:
            index += 1
            return children.ne
        case 2:
            index += 1
            return children.sw
        case 3:
            index += 1
            return children.se
        default:
            index += 1
            return nil
        }
    }
}

enum QuadTreeNodeType {
    case leaf
    case cluster(children: QuadTreeNodeChildren)
}
