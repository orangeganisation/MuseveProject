//
//  CustomPointAnnotation.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/24/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import MapKit
import UIKit

final class CustomPointAnnotation: MKPointAnnotation {
    var date: String?
    var location: String?
    var lineUp: String?
    
    func setDate(date: String) {
        if let settingDate = DateTimeFormatter.dateFormatter.date(from: date) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: settingDate)
            self.date = "\(settingDate.monthAsString()) \(components.day!), \(components.year!)"
        }
    }
}
