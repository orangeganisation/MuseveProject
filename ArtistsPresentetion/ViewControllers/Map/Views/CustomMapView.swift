//
//  CustomMapView.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/15/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import MapKit
import UIKit

final class CustomMapView: MKMapView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let subviewClass = NSClassFromString("MKCompassView"), let compassView = self.subviews.filter({ $0.isKind(of: subviewClass) }).first {
            compassView.frame.origin.y += CGFloat(45.0)
            compassView.frame.origin.x -= CGFloat(2.0)
        }
    }
    
}
