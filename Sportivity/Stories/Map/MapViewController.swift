//
//  MapViewController.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 08/06/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit

private struct MapViewControllerConstants {
    static let clusterAnnotationReuseId = "cluster"
    static let placeAnnotationReuseId = "place"
    static let clusteringEnabled = false
    static let useApplePins = true
    static let calloutImageWidth = 300
    static let calloutImageHeight = 200
}

private typealias C = MapViewControllerConstants

class MapViewController: UIViewController, ViewControllerProtocol, Configurable  {

    /// Tag of the view
    let viewTag : ViewTag = .events
    /// Main `DisposeBag` of the `ViewController`
    let disposeBag = DisposeBag()
    /// Observable that informs that `Router` should route to the `Route`
    let onRouteTo : Observable<Route> = PublishSubject<Route>()

    @IBOutlet fileprivate weak var mapView: MKMapView!
    fileprivate let clusterManager = ClusterManager()
    var viewModel: MapViewModel! = MapViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let center = CLLocationCoordinate2D(latitude: 52.2297, longitude: 21.0122)
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let region = MKCoordinateRegionMake(center, span)
        mapView.setRegion(region, animated: false)
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

private extension MapViewController {
    func bind() {
        viewModel
            .placeAnnotations
            .asObservable()
            .subscribeNext { [unowned self] (annotations) in
                if C.clusteringEnabled {
                    self.clusterManager.add(annotations)
                } else {
                    self.mapView.addAnnotations(annotations)
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func configureCalloutView(annotationView: MKAnnotationView) {
        guard
            let annotationView = annotationView as? PlacePinAnnotationView,
            let annotation = annotationView.annotation as? MapAnnotation else {
                assert(false, "Wrong annotation type")
                return
        }
        
        let view = UIView()
        let views = ["view": view]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view(\(C.calloutImageWidth))]", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view(\(C.calloutImageHeight))]", options: [], metrics: nil, views: views))
        
        let frame = CGRect(x: 0, y: 0, width: C.calloutImageWidth, height: C.calloutImageHeight)
        let imageView = UIImageView(frame: frame)
        switch annotation.type {
        case .place(let id, let category, let photoUrl):
            if let url = photoUrl {
                imageView.kf.setImage(with: url)
            } else if let category = category {
                let image = category.iconImage
                imageView.contentMode = .scaleAspectFit
                imageView.image = image
            } else {
                imageView.contentMode = .scaleAspectFill
                imageView.image = nil
            }
            
            let tapGesture = UITapGestureRecognizer()
            tapGesture
                .rx.event
                .map({ (recognizer) -> Route in
                    return Route(to: .place, type: nil, data: id)
                })
                .bind(to: onRouteTo.asPublishSubject()!)
                .addDisposableTo(annotationView.reuseBag)
            view.addGestureRecognizer(tapGesture)
        default:
            assert(false, "Wrong annotation type")
        }
        view.addSubview(imageView)
        
        annotationView.detailCalloutAccessoryView = view
    }
}

extension MapViewController : MKMapViewDelegate {
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if C.clusteringEnabled {
            self.clusterManager.mapViewChanged(mapView, visibleMapRect: mapView.visibleMapRect)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let color = R.color.sportivity.sunsetOrange()
        
        var view: MKAnnotationView!
        guard let annotation = annotation as? MapAnnotation else {
            assert(false)
            return nil
        }
        
        switch annotation.type {
        case .place:
            if C.useApplePins {
                view = mapView.dequeueReusableAnnotationView(withIdentifier: C.placeAnnotationReuseId) as? MKPinAnnotationView
            } else {
                view = mapView.dequeueReusableAnnotationView(withIdentifier: C.placeAnnotationReuseId) as? PlaceAnnotationView
            }
            
            if let view = view {
                view.annotation = annotation
            } else {
                if C.useApplePins {
                    let pinView = PlacePinAnnotationView(annotation: annotation, reuseIdentifier: C.placeAnnotationReuseId)
                    if #available(iOS 9.0, *) {
                        pinView.pinTintColor = color
                    } else {
                        pinView.pinColor = .red
                    }
                    view = pinView
                } else {
                    let placeView = PlaceAnnotationView(annotation: annotation, reuseIdentifier: C.placeAnnotationReuseId)
                    view = placeView
                }
            }
            
            view.canShowCallout = true
            self.configureCalloutView(annotationView: view)
        case .cluster(_):
            view = mapView.dequeueReusableAnnotationView(withIdentifier: C.clusterAnnotationReuseId)
            if let view = view {
                view.annotation = annotation
            } else {
                view = ClusterAnnotationView(annotation: annotation, reuseIdentifier: C.clusterAnnotationReuseId, color: color)
            }
            
            view.canShowCallout = false
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if C.clusteringEnabled {
            clusterManager.mapViewChanged(mapView, visibleMapRect: mapView.visibleMapRect)
        }
    }
}
