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
    var artist: (name: String, upcominIvents: Int)?
    
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
            DataStore.Events.eventsFilter = "upcoming"
            loadEvents()
        case 1:
            DataStore.Events.eventsFilter = "past"
            loadEvents()
        default:
            DataStore.Events.eventsFilter = "all"
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
        if DataStore.Events.shouldUpdateEvents {
            loadEvents()
        } else {
            if DataStore.Events.eventsFilter == "upcomimg" || DataStore.Events.eventsFilter == "past" || DataStore.Events.eventsFilter == "all" || DataStore.Events.eventsFilter == nil {
                eventsFilterSegment.alpha = 1.0
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        DataStore.Events.shouldUpdateEvents = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataStore.Events.eventsFilter = nil
        if artist!.upcominIvents == 0 {
            DataStore.Events.eventsFilter = "all"
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
        if let artistName = artist {
            if let named = artistName.name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
                InternetDataManager.shared.getEvents(forArtist: named, forDate: DataStore.Events.eventsFilter, viewController: self) { (error, artEvents) in
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
                        if DataStore.Events.eventsFilter != "upcoming", DataStore.Events.eventsFilter != nil {
                            DataStore.Events.events = artEvents!.reversed()
                        } else {
                            DataStore.Events.events = artEvents!
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
        return DataStore.Events.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return EventsTableViewCell.configuredCell(of: tableView, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let eventUrl = DataStore.Events.events[indexPath.row].getUrl() {
            if let url = URL(string: eventUrl) {
                InternetDataManager.openSafariPage(withUrl: url, byController: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .normal, title: NSLocalizedString("Show on map", comment: "")) { (rowAction, indexPath) in
            DataStore.Map.presentingEvents.append(DataStore.Events.events[indexPath.row])
            DataStore.Map.currentEventsArtistName = self.artist?.name
            DataStore.Map.needSetCenterMap = false
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
