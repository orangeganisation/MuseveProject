//
//  ExtensionDate.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 4/2/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation

extension Date {
    func monthAsString() -> String {
        let dataFormat = DateFormatter()
        dataFormat.setLocalizedDateFormatFromTemplate("MMM")
        return dataFormat.string(from: self)
    }
}
