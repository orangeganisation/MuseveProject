//
//  EventsTableViewCell.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/22/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import UIKit

final class EventsTableViewCell: UITableViewCell {

    @IBOutlet private weak var monthLabel: UILabel!
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var participantsLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var placeNameLabel: UILabel!
    
    func configureCell(at indexPath: IndexPath, byData event: Event) {
        let venue = event.situation
        cityLabel.text = venue?.city
        countryLabel.text = venue?.country
        placeNameLabel.text = venue?.name
        participantsLabel.text = event.getParticipants()
        let dateTime = event.datetime
        if let date = DateTimeFormatter.dateFormatter.date(from: dateTime) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            if let day = components.day, let year = components.year {
                dayLabel.text = String(day)
                yearLabel.text = String(year)
            }
            monthLabel.text = date.monthAsString()
        }
    }
}
