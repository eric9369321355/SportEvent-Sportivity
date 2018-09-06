//
//  EventProfileHeaderTableViewCell.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 25/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import Kingfisher

class EventProfileHeaderTableViewCell: UITableViewCell, Configurable {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var hostLabel: UILabel!
    @IBOutlet weak var attendButton: ActionButton!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var attendeesHeaderLabel: UILabel!
    
    var reuseBag = DisposeBag()
    private let disposeBag = DisposeBag()
    
    var viewModel: EventProfileHeaderViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mapView.showsUserLocation = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
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

        Observable
            .combineLatest(viewModel.date.asObservable(), viewModel.attendingCount.asObservable()) { (date, attendingCount) -> String in
                var text = date ?? ""
                if attendingCount > 0 {
                    text = (text.isEmpty ? "\(attendingCount) attending" : (text + "  •  \(attendingCount) attending"))
                }
                return text
            }
            .asDriver(onErrorJustReturn: "")
            .drive(dateLabel.rx.text)
            .addDisposableTo(reuseBag)
        
        viewModel.hostText.drive(hostLabel.rx.text).addDisposableTo(reuseBag)
        viewModel.placeName.drive(placeNameLabel.rx.text).addDisposableTo(reuseBag)
        viewModel.street.drive(addressLabel.rx.text).addDisposableTo(reuseBag)
        viewModel.city.drive(cityLabel.rx.text).addDisposableTo(reuseBag)
        
        viewModel
            .isAttending
            .asObservable()
            .subscribeNext { [unowned self] (isAttending) in
                if isAttending {
                    self.attendButton.setTitle("LEAVE", for: .normal)
                } else {
                    self.attendButton.setTitle("JOIN", for: .normal)
                }
            }
            .addDisposableTo(reuseBag)
        
        attendButton
            .rx.tap
            .asObservable()
            .subscribeNext { [unowned self] () in
                self.viewModel.toggleAttend.onNext()
            }
            .addDisposableTo(disposeBag)
        
        viewModel
            .placeLoc
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
            .combineLatest(mapTap.rx.event.asObservable(), viewModel.placeLoc.asObservable(), viewModel.placeName.asObservable()) { (_, loc, name) -> Void in
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
        
        Observable
            .combineLatest(viewModel.attendingCount.asObservable(), viewModel.capacity.asObservable()) { (count, capacity) -> String in
                guard let capacity = capacity else { return "WHO?" }
                return "\(count)/\(capacity) ATTENDING"
            }
            .bind(to: attendeesHeaderLabel.rx.text)
            .addDisposableTo(disposeBag)
    }
}
