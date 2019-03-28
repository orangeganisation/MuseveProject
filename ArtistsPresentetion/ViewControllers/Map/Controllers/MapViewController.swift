//
//  MapViewController.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/15/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {
    
    // MARK: - Vars
    var locationManager: CLLocationManager?
    var currentLocation: MKUserLocation?
    
    // MARK: - Outlets
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var myMapView: CustomMapView! {
        didSet {
            myMapView.delegate = self
        }
    }
    @IBOutlet weak var annotationView: UIStackView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var lineupLabel: UILabel!
    
    
    // MARK: - MapActions
    @IBAction func finduserLocation(_ sender: Any) {
        if let location = currentLocation {
            let region = MKCoordinateRegion (
                center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
            myMapView.setRegion(region, animated: true)
            if let imageFilled = UIImage(named: "buttonFilled.svg") {
                locationButton.setImage(imageFilled, for: .normal)
            }
        } else {
            Alerts.presentLocationServicesAlert(viewController: self)
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
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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
                mark.subtitle = event.getDescription() ?? "There is no description"
                mark.coordinate = CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longtitude)!)
                let dateFormatterGet = DateFormatter()
                dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                if let dateString = event.getDatetime() {
                    let date = dateFormatterGet.date(from: dateString)!
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
                    mark.date = "\(date.monthAsString()) \(components.day!), \(components.year!)"
                }
                mark.location = ""
                var noRegionAppend = ""
                if event.getVenue()?.getRegion() != nil {
                    noRegionAppend = ", "
                }
                mark.location?.append("\(event.getVenue()?.getCountry() ?? ""), ")
                mark.location?.append("\(event.getVenue()?.getRegion() ?? "")\(noRegionAppend)")
                mark.location?.append("\(event.getVenue()?.getCity() ?? "")")
                if let lineUp = event.getLineup() {
                    var lineUpString = String()
                    for participant in lineUp {
                        if participant == lineUp.last {
                            lineUpString.append(participant)
                        } else {
                            lineUpString.append("\(participant), ")
                        }
                    }
                    mark.lineUp = lineUpString
                }
                myMapView.addAnnotation(mark)
                if presentingEvents.count == 1 {
                    completion(Double(latitude)!, Double(longtitude)!)
                }
            }
        }
    }
}

// MARK: - MapViewControllerExtension
extension MapViewController{
    func mapView(_ mapView: MKMapView, didUpdate
        userLocation: MKUserLocation) {
        currentLocation = userLocation
        if DataStore.shared.needSetCenterMap {
            DataStore.shared.needSetCenterMap = false
            if let userLocation = mapView.userLocation.location?.coordinate {
                mapView.setCenter(userLocation, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if currentLocation != nil {
            if let imageFilled = UIImage(named: "buttonEmpty.svg"){
                locationButton.setImage(imageFilled, for: .normal)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !annotation.isEqual(mapView.userLocation) {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
            annotationView.canShowCallout = true
            if CoreDataManager.instance.objectIsInDataBase(objectName: (DataStore.shared.currentEventsArtist?.name)!, forEntity: "FavoriteArtist") {
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
        if let annotation = view.annotation as? CustomPointAnnotation {
            if !annotation.isEqual(mapView.userLocation) {
                let dateLabelText = dateLabel.text!
                dateLabel.text!.removeSubrange(dateLabelText.index(dateLabelText.firstIndex(of: ":")!, offsetBy: 2)...)
                let locationLabelText = locationLabel.text!
                locationLabel.text!.removeSubrange(locationLabelText.index(locationLabelText.firstIndex(of: ":")!, offsetBy: 2)...)
                let lineupLabelText = lineupLabel.text!
                lineupLabel.text!.removeSubrange(lineupLabelText.index(lineupLabelText.firstIndex(of: ":")!, offsetBy: 2)...)
                (annotationView.subviews[0] as! UILabel).text!.append(annotation.date ?? "no information")
                (annotationView.subviews[1] as! UILabel).text!.append((annotation.location ?? "no information"))
                (annotationView.subviews[2] as! UILabel).text!.append((annotation.lineUp ?? "no information"))
                view.detailCalloutAccessoryView = annotationView
                annotationView.isHidden = false
            }
        }
    }
}


