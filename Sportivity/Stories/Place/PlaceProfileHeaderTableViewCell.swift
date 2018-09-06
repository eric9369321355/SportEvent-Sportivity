//
//  PlaceProfileHeaderTableViewCell.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 09/07/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import Kingfisher

class PlaceProfileHeaderTableViewCell: UITableViewCell, Configurable {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var reuseBag = DisposeBag()
    private let disposeBag = DisposeBag()
    
    var viewModel: PlaceProfileHeaderViewModel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseBag = DisposeBag()
    }
    
    func configure() {
        viewModel.name.drive(nameLabel.rx.text).addDisposableTo(reuseBag)
        viewModel
            .photoUrl
            .driveNext { [unowned self] (url) in
                self.photoImageView.kf.setImage(with: url)
            }
            .addDisposableTo(reuseBag)
        viewModel.street.drive(addressLabel.rx.text).addDisposableTo(reuseBag)
        viewModel.city.drive(cityLabel.rx.text).addDisposableTo(reuseBag)
        
        viewModel
            .categories
            .map { (categories) -> String in
                let text = categories.reduce("Sports: ", { (text, cat) -> String in
                    return text == "Sports: " ? (text + cat.rawValue) : "\(text), \(cat.rawValue)"
                })
                return text == "Sports: " ? "" : text
            }
            .drive(categoriesLabel.rx.text)
            .addDisposableTo(reuseBag)
        
        viewModel
            .loc
            .driveNext { [unowned self] (loc) in
                guard let lat = loc?.lat, let lon = loc?.lon else { return }
                let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: center, span: span)
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                self.mapView.setRegion(region, animated: true)
                self.mapView.addAnnotation(annotation)
            }
            .addDisposableTo(disposeBag)
        
        let mapTap = UITapGestureRecognizer()
        
        Observable
            .combineLatest(mapTap.rx.event.asObservable(), viewModel.loc.asObservable(), viewModel.name.asObservable()) { (_, loc, name) -> Void in
                guard let lat = loc?.lat, let lon = loc?.lon else { return }
                let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                //let region = MKCoordinateRegion(center: center, span: span)
                let options: [String:Any] = [
                    MKLaunchOptionsMapCenterKey : center,
                    MKLaunchOptionsMapSpanKey : span
                ]
                
                let placemark = MKPlacemark(coordinate: center, addressDictionary: nil)
                let mapitem = MKMapItem(placemark: placemark)
                mapitem.name = name
                mapitem.openInMaps(launchOptions: options)
            }
            .subscribeNext { (_) in
                print("navigate to maps")
            }
            .addDisposableTo(disposeBag)
        
        mapView.addGestureRecognizer(mapTap)
    }
}
