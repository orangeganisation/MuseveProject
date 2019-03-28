//
//  EventsTableViewCell.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/22/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import UIKit

class EventsTableViewCell: UITableViewCell {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var participantsLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var placeNameLabel: UILabel!
    
    static func configuredCell(of tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventsTableViewCell
        let event = DataStore.shared.events[indexPath.row]
        let venue = event.getVenue()
        cell.cityLabel.text = venue?.getCity()
        cell.countryLabel.text = venue?.getCountry()
        cell.placeNameLabel.text = venue?.getName()
        var participants = ""
        var shouldEnter = true
        if let lineUp = event.getLineup() {
            for participant in lineUp {
                if shouldEnter {
                    participants.append(participant)
                    shouldEnter = false
                } else {
                    participants.append("\n\(participant)")
                }
            }
        }
        cell.participantsLabel.text = participants
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if let dateTime = event.getDatetime() {
            let date = dateFormatter.date(from: dateTime)!
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            cell.dayLabel.text = String(components.day!)
            cell.yearLabel.text = String(components.year!)
            cell.monthLabel.text = date.monthAsString()
        }
        return cell
    }
}
