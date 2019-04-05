//
//  MapViewController.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/15/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import CoreData
import CoreLocation
import MapKit
import UIKit

final class MapViewController: UIViewController {
    
    // MARK: - Vars & Lets
    private var locationManager: CLLocationManager?
    private var currentLocation: MKUserLocation?
    private let dataStore = DataStore.shared
    private let coreDataInstance = CoreDataManager.instance
    
    // MARK: - Outlets
    @IBOutlet private weak var locationButton: UIButton!
    @IBOutlet private weak var annotationView: UIStackView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var lineupLabel: UILabel!
    @IBOutlet private weak var myMapView: CustomMapView! {
        didSet {
            myMapView.delegate = self
        }
    }
    
    
    // MARK: - MapActions
    @IBAction func showUserLocation(_ sender: UIButton) {
        if let location = currentLocation {
            if let imageFilled = UIImage(named: "buttonFilled.svg") {
                locationButton.setImage(imageFilled, for: .normal)
            }
            let region = MKCoordinateRegion (
                center: location.coordinate,
                latitudinalMeters: CLLocationDistance(IntConstant.regionScale),
                longitudinalMeters: CLLocationDistance(IntConstant.regionScale))
            myMapView.setRegion(region, animated: true)
        } else {
            presentLocationFailedAlert()
        }
    }
    
    
    
    @IBAction func changeMapType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            myMapView.mapType = .mutedStandard
            locationButton.tintColor = #colorLiteral(red: 0.6600925326, green: 0.2217625678, blue: 0.3476891518, alpha: 1)
        default:
            myMapView.mapType = .hybrid
            locationButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    
    // MARK: - ViewController
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        myMapView.removeAnnotations(myMapView.annotations)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        setMarkersForEvents { (latitude, longtitude) in
            if let latitude = latitude, let longtitude = longtitude {
                let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
                let region = MKCoordinateRegion(
                    center: coordinates,
                    latitudinalMeters: CLLocationDistance(IntConstant.regionScale),
                    longitudinalMeters: CLLocationDistance(IntConstant.regionScale))
                myMapView.setRegion(region, animated: true)
            }
        }
    }
    
    
    // MARK: - MyTools
    func presentLocationFailedAlert() {
        let locationFailed = "Turn On Location Services".localized()
        let alert = UIAlertController(title: "Location Services".localized(), message: locationFailed, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: StringConstant.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: StringConstant.settings, style: .default, handler: { (action) in
            if let url = URL(string: Alerts.settingsUrl) { UIApplication.shared.open(url) }
        }))
        present(alert, animated: true)
    }
    
    func setMarkersForEvents(completion: (_ latitude: Double?,_ longtitude: Double?) -> Void) {
        let presentingEvents = dataStore.presentingEvents
        for event in presentingEvents {
            if let latitude = event.situation?.latitude, let longtitude = event.situation?.longitude {
                let mark = CustomPointAnnotation()
                mark.title = event.situation?.name
                if let latitude = Double(latitude), let longtitude = Double(longtitude) {
                    mark.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
                }
                mark.setDate(date: event.datetime)
                if let eventVenue = event.situation {
                    var locationData = [String]()
                    locationData.append(eventVenue.country)
                    if let region = eventVenue.region, !region.isEmpty {
                        locationData.append(region)
                    }
                    locationData.append(eventVenue.city)
                    mark.location = locationData.joined(separator: ", ")
                }
                if let lineUp = event.lineUp {
                    mark.lineUp = lineUp.joined(separator: ", ")
                }
                myMapView.addAnnotation(mark)
                if dataStore.needSetCenterMap {
                    dataStore.needSetCenterMap = false
                    if let latitudeCoordinates = presentingEvents.last?.situation?.latitude,
                        let lastLatitude = Double(latitudeCoordinates),
                        let longtitudeCoordinates = presentingEvents.last?.situation?.longitude,
                        let lastLongtitude = Double(longtitudeCoordinates) {
                        completion(lastLatitude, lastLongtitude)
                    }
                }
            }
        }
    }
}

// MARK: - MapViewControllerExtension
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate
        userLocation: MKUserLocation) {
        currentLocation = userLocation
        if dataStore.needSetCenterMap {
            dataStore.needSetCenterMap = false
            if let userLocation = mapView.userLocation.location?.coordinate {
                mapView.setCenter(userLocation, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if currentLocation != nil, let imageFilled = UIImage(named: "buttonEmpty.svg"), !animated {
            locationButton.setImage(imageFilled, for: .normal)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !annotation.isEqual(mapView.userLocation) {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
            annotationView.canShowCallout = true
            let name = dataStore.presentingOnMapArtist.name
            annotationView.markerTintColor = coreDataInstance.objectIsInDataBase(objectName: name, forEntity: StringConstant.favoriteArtistEntity) ? #colorLiteral(red: 0.6600925326, green: 0.2217625678, blue: 0.3476891518, alpha: 1) : #colorLiteral(red: 0.1531656981, green: 0.1525758207, blue: 0.1700873673, alpha: 1)
            return annotationView
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? CustomPointAnnotation, !annotation.isEqual(mapView.userLocation) {
            let noInfo = "no information".localized()
            dateLabel?.text = "Date: ".localized() + (annotation.date ?? noInfo)
            locationLabel?.text = "Location: ".localized() + (annotation.location ?? noInfo)
            lineupLabel?.text = "Line-up: ".localized() + (annotation.lineUp ?? noInfo)
            view.detailCalloutAccessoryView = annotationView
            annotationView.isHidden = false
        }
    }
}


