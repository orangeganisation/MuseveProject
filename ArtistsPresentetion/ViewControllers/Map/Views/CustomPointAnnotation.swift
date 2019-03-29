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
        self.date = date
    }
    
    func setLocation(location: String) {
        self.location = location
    }
    
    func setLineUp(lineUp: String) {
        self.lineUp = lineUp
    }
}
