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
    
    private static let dataLoadingFailed = "Failed to load data".localized()
    private static let internetProblems = "Problem with internet connection".localized()
    static let settingsUrl = "App-Prefs:"
    
    static func presentConnectionAlert() {
        let alert = UIAlertController(title: "Internet Connection".localized(), message: internetProblems, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: StringConstant.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: StringConstant.settings, style: .default, handler: { (action) in
            if let url = URL(string: settingsUrl) { UIApplication.shared.open(url) }
        }))
        if let window = UIApplication.shared.keyWindow, let topViewController = window.rootViewController {
            topViewController.present(alert, animated: true)
        }
    }
    
    
    static func presentFailedDataLoadingAlert() {
        let alert = UIAlertController(title: "Data Loading".localized(), message: dataLoadingFailed, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: StringConstant.ok, style: .cancel))
        if let window = UIApplication.shared.keyWindow, let topViewController = window.rootViewController {
            topViewController.present(alert, animated: true)
        }
    }
    
}
