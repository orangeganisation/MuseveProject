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
    
    // MARK: - Vars
    private var locationManager: CLLocationManager?
    private var currentLocation: MKUserLocation?
    private let dataStore = DataStore.shared
    
    // MARK: - Outlets
    @IBOutlet private weak var locationButton: UIButton!
    @IBOutlet private weak var myMapView: CustomMapView! {
        didSet {
            myMapView.delegate = self
        }
    }
    @IBOutlet private weak var annotationView: UIStackView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var lineupLabel: UILabel!
    
    
    // MARK: - MapActions
    @IBAction func showUserLocation(_ sender: UIButton) {
        if let location = currentLocation {
            let region = MKCoordinateRegion (
                center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
            myMapView.setRegion(region, animated: true)
            if let imageFilled = UIImage(named: "buttonFilled.svg") {
                locationButton.setImage(imageFilled, for: .normal)
            }
        } else {
            let locationFailed = NSLocalizedString("Turn On Location Services to allow \"Museve\" to determine Your location:\nSettings->Privacy->Location Services", comment: "")
            let alert = UIAlertController(title: NSLocalizedString("Location Services", comment: ""), message: locationFailed, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: StringConstants.AlertsStrings.cancel, style: .cancel))
            alert.addAction(UIAlertAction(title: StringConstants.AlertsStrings.settings, style: .default, handler: { (action) in
                if let url = URL(string: Alerts.settingsUrl) { UIApplication.shared.open(url) }
            }))
            present(alert, animated: true)
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
                let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 2000, longitudinalMeters: 2000)
                myMapView.setRegion(region, animated: true)
            }
        }
    }
    
    
    // MARK: - MyTools
    func setMarkersForEvents(completion: (_ latitude: Double?,_ longtitude: Double?) -> Void) {
        let presentingEvents = DataStore.shared.presentingEvents
        for event in presentingEvents {
            if let latitude = event.getVenue()?.getLatitude(), let longtitude = event.getVenue()?.getLongtitude() {
                let mark = CustomPointAnnotation()
                mark.title = event.getVenue()?.getName()
                if let latitude = Double(latitude), let longtitude = Double(longtitude) {
                    mark.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
                }
                if let eventDate = event.getDatetime() {
                    mark.setDate(date: eventDate)
                }
                mark.setLocation(location: "")
                var noRegionAppend = ""
                if let eventVenue = event.getVenue() {
                    mark.setLocation(location: (mark.getLocation() ?? "") + "\(eventVenue.getCountry() ?? ""), ")
                    if let eventRegion = event.getVenue()?.getRegion() , !eventRegion.isEmpty {
                        noRegionAppend = ", "
                    }
                    mark.setLocation(location: (mark.getLocation() ?? "") + "\(eventVenue.getRegion() ?? "")\(noRegionAppend)")
                    mark.setLocation(location: (mark.getLocation() ?? "") + "\(eventVenue.getCity() ?? "")")
                }
                if let lineUp = event.getLineup() {
                    var lineUpString = String()
                    for participant in lineUp {
                        if participant == lineUp.last {
                            lineUpString.append(participant)
                        } else {
                            lineUpString.append("\(participant), ")
                        }
                    }
                    mark.setLineUp(lineUp: lineUpString)
                }
                myMapView.addAnnotation(mark)
                if dataStore.needSetCenterMap {
                    DataStore.shared.needSetCenterMap = false
                    if let latitudeCoordinates = presentingEvents.last?.getVenue()?.getLatitude(),
                        let lastLatitude = Double(latitudeCoordinates),
                        let longtitudeCoordinates = presentingEvents.last?.getVenue()?.getLongtitude(),
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
            DataStore.shared.needSetCenterMap = false
            if let userLocation = mapView.userLocation.location?.coordinate {
                mapView.setCenter(userLocation, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if currentLocation != nil, let imageFilled = UIImage(named: "buttonEmpty.svg") {
            locationButton.setImage(imageFilled, for: .normal)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !annotation.isEqual(mapView.userLocation) {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
            annotationView.canShowCallout = true
            let name = dataStore.presentingOnMapArtist.getName()
            if CoreDataManager.instance.objectIsInDataBase(objectName: name, forEntity: StringConstants.Favorites.entity) {
                annotationView.markerTintColor = #colorLiteral(red: 0.6600925326, green: 0.2217625678, blue: 0.3476891518, alpha: 1)
            } else {
                annotationView.markerTintColor = #colorLiteral(red: 0.1531656981, green: 0.1525758207, blue: 0.1700873673, alpha: 1)
            }
            return annotationView
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? CustomPointAnnotation, !annotation.isEqual(mapView.userLocation) {
            if let dateLabelText = dateLabel.text, let dateIndex = dateLabelText.firstIndex(of: ":"),
                let locationLabelText = locationLabel.text, let locationIndex = locationLabelText.firstIndex(of: ":"),
                let lineupLabelText = lineupLabel.text, let lineUpIndex = lineupLabelText.firstIndex(of: ":") {
                dateLabel.text?.removeSubrange(dateLabelText.index(dateIndex, offsetBy: 2)...)
                locationLabel.text?.removeSubrange(locationLabelText.index(locationIndex, offsetBy: 2)...)
                lineupLabel.text?.removeSubrange(lineupLabelText.index(lineUpIndex, offsetBy: 2)...)
            }
            let noInfo = NSLocalizedString("no information", comment: "")
            (annotationView.subviews[0] as? UILabel)?.text?.append(annotation.getDate() ?? noInfo)
            (annotationView.subviews[1] as? UILabel)?.text?.append((annotation.getLocation() ?? noInfo))
            (annotationView.subviews[2] as? UILabel)?.text?.append((annotation.getLineUp() ?? noInfo))
            view.detailCalloutAccessoryView = annotationView
            annotationView.isHidden = false
        }
    }
}


