//
//  InternetManager.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/19/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation
import UIKit

class InternetDataManager{
    
    
    
    
    func presentConnectionAlert(viewController:UIViewController){
        let alert = UIAlertController(title: "Internet Connection", message: "There is a problem with internet connection. Please, turn ON cellular or connect to WiFi", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: StringConstants().cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: StringConstants().settings, style: .default, handler: { (action) in
            UIApplication.shared.open(URL(string: "App-Prefs:")!)
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
}
