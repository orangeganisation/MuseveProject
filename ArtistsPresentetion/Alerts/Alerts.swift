//
//  Alerts.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 3/4/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation
import UIKit

final class Alerts {
    
    private static let dataLoadingFailed = NSLocalizedString("Failed to load data. Please, try again later.", comment: "")
    private static let internetProblems = NSLocalizedString("There is a problem with internet connection. Please, turn ON cellular or connect to WiFi.", comment: "")
    static let settingsUrl = "App-Prefs:"
    
    static func presentConnectionAlert(viewController: UIViewController) {
        let alert = UIAlertController(title: NSLocalizedString("Internet Connection", comment: ""), message: internetProblems, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: StringConstants.AlertsStrings.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: StringConstants.AlertsStrings.settings, style: .default, handler: { (action) in
            if let url = URL(string: settingsUrl) { UIApplication.shared.open(url) }
        }))
        viewController.present(alert, animated: true)
    }
    
    
    static func presentFailedDataLoadingAlert(viewController: UIViewController) {
        let alert = UIAlertController(title: NSLocalizedString("Data Loading", comment: ""), message: dataLoadingFailed, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: StringConstants.AlertsStrings.ok, style: .cancel))
        viewController.present(alert, animated: true)
    }
    
}
