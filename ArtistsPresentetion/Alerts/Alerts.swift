//
//  Alerts.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 3/4/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation
import UIKit

class Alerts {
    
    static func presentConnectionAlert(viewController: UIViewController){
        let alert = UIAlertController(title: NSLocalizedString("Internet Connection", comment: ""), message: NSLocalizedString("There is a problem with internet connection. Please, turn ON cellular or connect to WiFi.", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: StringConstants.AlertsStrings.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: StringConstants.AlertsStrings.settings, style: .default, handler: { (action) in
            UIApplication.shared.open(URL(string: "App-Prefs:")!)
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    
    static func presentFailedDataLoadingAlert(viewController: UIViewController){
        let alert = UIAlertController(title: NSLocalizedString("Data Loading", comment: ""), message: StringConstants.AlertsStrings.dataLoadingFailed, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: StringConstants.AlertsStrings.ok, style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func presentLocationServicesAlert(viewController: UIViewController) {
        let alert = UIAlertController(title: NSLocalizedString("Location Services", comment: ""), message: StringConstants.AlertsStrings.locationFailed, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: StringConstants.AlertsStrings.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: StringConstants.AlertsStrings.settings, style: .default, handler: { (action) in
            UIApplication.shared.open(URL(string: "App-Prefs:")!)
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
    
}
