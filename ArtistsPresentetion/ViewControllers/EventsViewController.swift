//
//  EventsViewController.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/22/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController, UITableViewDataSource {

    // MARK: - Vars
    static let shared = EventsViewController()
    var artist: (name: String, upcominIvents: Int)?
    var eventsFilter: String?
    var shouldUpdateEvents = false
    var events = [Event]()
    
    // MARK: - Outlets
    @IBOutlet weak var haveNoEventsLabel: UILabel!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var loadingDataSpinner: UIActivityIndicatorView!
    @IBOutlet weak var eventsFilterSegment: UISegmentedControl! {
        didSet {
            for index in eventsFilterSegment.subviews.indices {
                eventsFilterSegment.setTitle(NSLocalizedString(eventsFilterSegment.titleForSegment(at: index)!, comment: ""), forSegmentAt: index)
            }
        }
    }
    @IBOutlet weak var navigationBar: UINavigationItem! {
        didSet {
            navigationBar.title = NSLocalizedString(navigationBar.title!, comment: "")
        }
    }
    
    
    
    // MARK: - Actions
    @IBAction func changeFilterInSegment(_ sender: UISegmentedControl) {
        eventsFilterSegment.alpha = 1
        switch eventsFilterSegment.selectedSegmentIndex {
        case 0:
            EventsViewController.shared.eventsFilter = "upcoming"
            loadEvents()
        case 1:
            EventsViewController.shared.eventsFilter = "past"
            loadEvents()
        default:
            EventsViewController.shared.eventsFilter = "all"
            loadEvents()
        }
    }
    
    @IBAction func sortEventsByDate(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Events", bundle: nil)
        let dateViewController = storyboard.instantiateViewController(withIdentifier: "datePickerViewController") as! DateViewController
        self.navigationController?.present(dateViewController, animated: true, completion: nil)
        eventsFilterSegment.alpha = 0.4
    }
    
    // MARK: - ViewController
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.view.layoutSubviews()
        if EventsViewController.shared.shouldUpdateEvents {
            loadEvents()
        } else {
            if EventsViewController.shared.eventsFilter == "upcomimg" || EventsViewController.shared.eventsFilter == "past" || EventsViewController.shared.eventsFilter == "all" || EventsViewController.shared.eventsFilter == nil {
                eventsFilterSegment.alpha = 1.0
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        EventsViewController.shared.shouldUpdateEvents = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EventsViewController.shared.eventsFilter = nil
        if EventsViewController.shared.artist!.upcominIvents == 0 {
            EventsViewController.shared.eventsFilter = "all"
            eventsFilterSegment.selectedSegmentIndex = 2
        } else {
            eventsFilterSegment.selectedSegmentIndex = 0
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
        if let artistName = EventsViewController.shared.artist {
            if let named = artistName.name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
                InternetDataManager.shared.getEvents(forArtist: named, forDate: EventsViewController.shared.eventsFilter, viewController: self) { (error, artEvents) in
                    DispatchQueue.main.async {
                        self.loadingDataSpinner.stopAnimating()
                    }
                    if error != nil {
                        DispatchQueue.main.async {
                            self.haveNoEventsLabel.text = NSLocalizedString("Failed", comment: "")
                            self.eventsTableView.isHidden = true
                            Alerts.presentFailedDataLoadingAlert(viewController: self)
                            self.haveNoEventsLabel.isHidden = false
                        }
                    } else if artEvents != nil, artEvents?.count != 0 {
                        if EventsViewController.shared.eventsFilter != "upcoming", EventsViewController.shared.eventsFilter != nil {
                            EventsViewController.shared.events = artEvents!.reversed()
                        } else {
                            EventsViewController.shared.events = artEvents!
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
                            self.haveNoEventsLabel.text = NSLocalizedString("No events", comment: "")
                            self.eventsTableView.isHidden = true
                            self.haveNoEventsLabel.isHidden = false
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.haveNoEventsLabel.text = NSLocalizedString("Failed", comment: "")
                            self.eventsTableView.isHidden = true
                            self.haveNoEventsLabel.isHidden = false
                            Alerts.presentFailedDataLoadingAlert(viewController: self)
                        }
                    }
                }
            }
        }
    }
}


// MARK: - Extensions
extension EventsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EventsViewController.shared.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return EventsTableViewCell.configuredCell(of: tableView, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let eventUrl = EventsViewController.shared.events[indexPath.row].getUrl() {
            if let url = URL(string: eventUrl) {
                InternetDataManager.openSafariPage(withUrl: url, byController: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .normal, title: NSLocalizedString("Show on map", comment: "")) { (rowAction, indexPath) in
            MapViewController.shared.presentingEvents.append(EventsViewController.shared.events[indexPath.row])
            MapViewController.shared.currentArtistName = EventsViewController.shared.artist?.name
            MapViewController.shared.needSetCenterValue = false
            self.tabBarController?.selectedIndex = 2
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
