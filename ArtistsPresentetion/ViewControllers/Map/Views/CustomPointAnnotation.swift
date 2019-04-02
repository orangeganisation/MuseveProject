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
    private var date: String?
    private var location: String?
    private var lineUp: String?
    
    func getDate() -> String? {
        return self.date
    }
    
    func getLocation() -> String? {
        return self.location
    }
    
    func getLineUp() -> String? {
        return self.lineUp
    }
    
    func setDate(date: String) {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let settingDate = dateFormatterGet.date(from: date) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: settingDate)
            self.date = "\(settingDate.monthAsString()) \(components.day!), \(components.year!)"
        }
    }
    
    func setLocation(location: String) {
        self.location = location
    }
    
    func setLineUp(lineUp: String) {
        self.lineUp = lineUp
    }
}
