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
    static var currentArtistId: String?
    static var currentArtistName: String?
    static var needSetCenterValue = true
    static var presentingEvents = [Event]()
    
    // MARK: - Outlets
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var myMapView: CustomMapView!{
        didSet{
            myMapView.delegate = self
        }
    }
    @IBOutlet weak var annotationView: UIStackView!    
    
    // MARK: - MapActions
    @IBAction func finduserLocation(_ sender: Any) {
        if let location = currentLocation{
            let region = MKCoordinateRegion(
                center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
            myMapView.setRegion(region, animated: true)
            if let imageFilled = UIImage(named: "buttonFilled.svg"){
                locationButton.setImage(imageFilled, for: .normal)
            }
        }else{
            let alert = UIAlertController(title: "Location Services", message: "Turn On Location Services to allow \"ArtEve\" to determine Your location:\nSettings->Privacy->Location Services", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: StringConstants.cancel, style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: StringConstants.settings, style: .default, handler: { (action) in
                UIApplication.shared.open(URL(string: "App-Prefs:")!)
            }))
            present(alert, animated: true, completion: nil)
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        MapViewController.presentingEvents.removeAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if MapViewController.presentingEvents.count > 1 {
            myMapView.removeAnnotations(myMapView.annotations)
        } else if MapViewController.presentingEvents.count == 1 {
            if MapViewController.presentingEvents[0].getArtistID() != MapViewController.currentArtistId {
                MapViewController.currentArtistId = MapViewController.presentingEvents[0].getArtistID()
                myMapView.removeAnnotations(myMapView.annotations)
            }
        }
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
        for event in MapViewController.presentingEvents {
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
                if let country = event.getVenue()?.getCountry(), !country.isEmpty {
                    mark.location?.append("\(country), ")
                } else {
                    mark.location?.append("")
                }
                if let region = event.getVenue()?.getRegion(), !region.isEmpty {
                    mark.location?.append("\(region), ")
                } else {
                    mark.location?.append("")
                }
                if let city = event.getVenue()?.getCity() {
                    mark.location?.append("\(city)")
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
                    mark.lineUp = lineUpString
                }
                myMapView.addAnnotation(mark)
                if MapViewController.presentingEvents.count == 1 {
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
        if MapViewController.needSetCenterValue {
            MapViewController.needSetCenterValue = false
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
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteArtist")
            annotationView.markerTintColor = #colorLiteral(red: 0.1531656981, green: 0.1525758207, blue: 0.1700873673, alpha: 1)
            do {
                let results = try CoreDataManager.instance.persistentContainer.viewContext.fetch(fetchRequest)
                for result in results as! [NSManagedObject] {
                    if (result.value(forKey: "name") as! String) == MapViewController.currentArtistName {
                        annotationView.markerTintColor = #colorLiteral(red: 0.6600925326, green: 0.2217625678, blue: 0.3476891518, alpha: 1)
                    }
                }
            } catch {
                print(error)
            }
            return annotationView
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? CustomPointAnnotation {
            if !annotation.isEqual(mapView.userLocation) {
                (annotationView.subviews[0] as! UILabel).text = "Date: " + (annotation.date ?? "no information")
                (annotationView.subviews[1] as! UILabel).text = "Location: " + (annotation.location ?? "no information")
                (annotationView.subviews[2] as! UILabel).text = "Line-up: " + (annotation.lineUp ?? "no information")
                view.detailCalloutAccessoryView = annotationView
                annotationView.isHidden = false
            }
        }
    }
}


