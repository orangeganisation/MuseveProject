//
//  EventsViewController.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/22/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Vars
    static var artist: (name: String, upcominIvents: Int)?
    var iventsFilter: String?
    var events = [Event]()
    
    // MARK: - Outlets
    @IBOutlet weak var haveNoEventsLabel: UILabel!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var loadingDataSpinner: UIActivityIndicatorView!
    @IBOutlet weak var iventsFilterSegment: UISegmentedControl!
    
    // MARK: - Actions
    @IBAction func changeFilterInSegment(_ sender: UISegmentedControl) {
        switch iventsFilterSegment.selectedSegmentIndex {
        case 0:
            iventsFilter = "upcoming"
            loadEvents()
        case 1:
            iventsFilter = "past"
            loadEvents()
        default:
            iventsFilter = "all"
            loadEvents()
        }
    }
    
    
    // MARK: - ViewController
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.view.layoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iventsFilter = nil
        if EventsViewController.artist!.upcominIvents == 0 {
            iventsFilter = "all"
            iventsFilterSegment.selectedSegmentIndex = 2
        } else {
            iventsFilterSegment.selectedSegmentIndex = 0
        }
        loadEvents()
    }
    
    // MARK: - MyTools
    func loadEvents() {
        UIView.animate(withDuration: 0.5) {
            self.eventsTableView.alpha = 0
        }
        haveNoEventsLabel.isHidden = true
        eventsTableView.isHidden = true
        loadingDataSpinner.startAnimating()
        if let artistName = EventsViewController.artist {
            if let named = artistName.name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
                SearchViewController.internetDataManager.getEvents(forArtist: named, forDate: iventsFilter, viewController: self) { (error, artEvents) in
                    DispatchQueue.main.async {
                        self.loadingDataSpinner.stopAnimating()
                    }
                    if error != nil {
                        DispatchQueue.main.async {
                            self.haveNoEventsLabel.text = "Failed"
                            self.eventsTableView.isHidden = true
                            SearchViewController.internetDataManager.presentFailedDataLoadingAlert(viewController: self)
                            self.haveNoEventsLabel.isHidden = false
                        }
                    } else if artEvents != nil, artEvents?.count != 0 {
                        if self.iventsFilter != "upcoming", self.iventsFilter != nil {
                            self.events = artEvents!.reversed()
                        } else {
                            self.events = artEvents!
                        }
                        DispatchQueue.main.async {
                            self.eventsTableView.isHidden = false
                            self.haveNoEventsLabel.isHidden = true
                            UIView.animate(withDuration: 0.5, animations: {
                                self.eventsTableView.alpha = 1.0
                            })
                            self.eventsTableView.reloadData()
                        }
                    } else if artEvents != nil {
                        DispatchQueue.main.async {
                            self.haveNoEventsLabel.text = "No events"
                            self.eventsTableView.isHidden = true
                            self.haveNoEventsLabel.isHidden = false
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.haveNoEventsLabel.text = "Failed"
                            self.eventsTableView.isHidden = true
                            self.haveNoEventsLabel.isHidden = false
                            SearchViewController.internetDataManager.presentFailedDataLoadingAlert(viewController: self)
                        }
                    }
                }
            }
        }
    }
}



extension EventsViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventsTableViewCell
        if let city = events[indexPath.row].getVenue()?.getCity() {
            cell.cityLabel.text = city
        }
        if let country = events[indexPath.row].getVenue()?.getCountry() {
            cell.countryLabel.text = country
        }
        if let place = events[indexPath.row].getVenue()?.getName() {
            cell.placeNameLabel.text = place
        }
        var participants = ""
        var participantIndex = 0
        if let lineUp = events[indexPath.row].getLineup() {
            for participant in lineUp {
                if participantIndex == 0 {
                    participants.append(participant)
                    participantIndex += 1
                } else {
                    participants.append("\n\(participant)")
                }
            }
        }
        cell.participantsLabel.text = participants
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if let dateTime = events[indexPath.row].getDatetime() {
            let date = dateFormatter.date(from: dateTime)!
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            cell.dayLabel.text = String(components.day!)
            cell.yearLabel.text = String(components.year!)
            cell.monthLabel.text = date.monthAsString()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let eventUrl = events[indexPath.row].getUrl() {
            if let url = URL(string: eventUrl) {
                InternetDataManager.openSafariPage(withUrl: url, byController: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .normal, title: "Show on map") { (rowAction, indexPath) in
//            let eventsMapStoryboard = UIStoryboard(name: "EventsMap", bundle: nil)
//            let mapViewController = eventsMapStoryboard.instantiateViewController(withIdentifier: "mapViewController") as! MapViewController
            //switch the controller and add a marker
        }
        action.backgroundColor = #colorLiteral(red: 0.6600925326, green: 0.2217625678, blue: 0.3476891518, alpha: 1)
        return [action]
    }
}

extension Date {
    func monthAsString() -> String {
        let dataFormat = DateFormatter()
        dataFormat.setLocalizedDateFormatFromTemplate("MMM")
        return dataFormat.string(from: self)
    }
}
