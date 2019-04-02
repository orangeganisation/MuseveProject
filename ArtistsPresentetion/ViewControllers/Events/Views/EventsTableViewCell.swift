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
    
    static func configuredCell(from cell: EventsTableViewCell, for indexPath: IndexPath) -> UITableViewCell {
        let event = DataStore.shared.loadedEvents[indexPath.row]
        let venue = event.getVenue()
        cell.cityLabel.text = venue?.getCity()
        cell.countryLabel.text = venue?.getCountry()
        cell.placeNameLabel.text = venue?.getName()
        cell.participantsLabel.text = event.getParticipants()
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if let dateTime = event.getDatetime(), let date = dateFormatter.date(from: dateTime) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            if let day = components.day, let year = components.year {
                cell.dayLabel.text = String(day)
                cell.yearLabel.text = String(year)
            }
            cell.monthLabel.text = date.monthAsString()
        }
        return cell
    }
}
