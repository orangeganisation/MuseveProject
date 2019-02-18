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

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Vars
    var locationManager: CLLocationManager?
    var currentLocation: MKUserLocation?
    var needSetCenterValue = true
    
    // MARK: - Outlets
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var myMapView: CustomMapView!{
        didSet{
            myMapView.delegate = self
        }
    }
    
    
    // MARK: - Actions
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
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                UIApplication.shared.open(URL(string: "App-Prefs:")!)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func changeMapType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            myMapView.mapType = .mutedStandard
            locationButton.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        default:
            myMapView.mapType = .hybrid
            locationButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    // MARK: - Map
    func mapView(_ mapView: MKMapView, didUpdate
        userLocation: MKUserLocation) {
        currentLocation = userLocation
        if needSetCenterValue{
            needSetCenterValue = false
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
    
    
    // MARK: - ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
