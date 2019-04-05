//
//  DateTimeFormatter.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 4/3/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation

final class DateTimeFormatter {
    static var dateFormatter: DateFormatter {
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter
    }
}
