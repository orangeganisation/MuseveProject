//
//  EventsViewController.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/22/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import SafariServices
import UIKit

final class EventsViewController: UIViewController {
    
    // MARK: - Vars
    private let dataStore = DataStore.shared
    
    // MARK: - Outlets
    @IBOutlet private weak var haveNoEventsLabel: UILabel!
    @IBOutlet private weak var eventsTableView: UITableView!
    @IBOutlet private weak var loadingDataSpinner: UIActivityIndicatorView!
    @IBOutlet private weak var eventsFilterSegment: UISegmentedControl! {
        didSet {
            for index in eventsFilterSegment.subviews.indices {
                eventsFilterSegment.setTitle(NSLocalizedString(eventsFilterSegment.titleForSegment(at: index)!, comment: ""), forSegmentAt: index)
            }
        }
    }
    @IBOutlet private weak var navigationBar: UINavigationItem! {
        didSet {
            navigationBar.title = NSLocalizedString(navigationBar.title!, comment: "")
        }
    }
    
    
    
    // MARK: - Actions
    @IBAction func changeFilterInSegment(_ sender: UISegmentedControl) {
        eventsFilterSegment.alpha = 1
        switch eventsFilterSegment.selectedSegmentIndex {
        case 0: DataStore.shared.eventsFilter = "upcoming"
        case 1: DataStore.shared.eventsFilter = "past"
        default: DataStore.shared.eventsFilter = "all"
        }
        loadEvents()
    }
    
    @IBAction func sortEventsByDate(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Events", bundle: nil)
        if let dateViewController = storyboard.instantiateViewController(withIdentifier: "datePickerViewController") as? DateViewController {
            navigationController?.present(dateViewController, animated: true)
            eventsFilterSegment.alpha = 0.4
        }
    }
    
    // MARK: - ViewController
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.view.layoutSubviews()
        if dataStore.shouldUpdateEvents {
            loadEvents()
        } else if dataStore.isEventsFilterSettedBySegment() {
            eventsFilterSegment.alpha = 1.0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        dataStore.resetEventsFilter()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataStore.shared.eventsFilter = nil
        if DataStore.shared.presentingOnMapArtist.getUpcomingEventCount() == 0 {
            DataStore.shared.eventsFilter = "all"
            eventsFilterSegment.selectedSegmentIndex = 2
        } else {
            eventsFilterSegment.selectedSegmentIndex = 0
        }
        loadEvents()
    }
    
    // MARK: - MyTools
    func presentEventsLoadingFail(message: String) {
        self.haveNoEventsLabel.text = NSLocalizedString(message, comment: "")
        self.eventsTableView.isHidden = true
        self.haveNoEventsLabel.isHidden = false
    }
    
    static func openSafariPage(withUrl url: URL, byController viewController: UIViewController) {
        let safari = SFSafariViewController(url: url)
        safari.preferredBarTintColor = #colorLiteral(red: 0.1660079956, green: 0.1598443687, blue: 0.1949053109, alpha: 1)
        viewController.present(safari, animated: true)
    }
    
    func loadEvents() {
        UIView.animate(withDuration: 0.5) {
            self.eventsTableView.alpha = 0
        }
        haveNoEventsLabel.isHidden = true
        eventsTableView.isHidden = true
        loadingDataSpinner.startAnimating()
        if let named = DataStore.shared.presentingOnMapArtist.getName().addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            let eventsFilter = dataStore.eventsFilter
            if InternetDataManager.shared.isConnectedToNetwork() {
                InternetDataManager.shared.getEvents(forArtist: named) { (error, artEvents) in
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
                    } else if let artEvents = artEvents, artEvents.count != 0 {
                        if eventsFilter != "upcoming", eventsFilter != nil {
                            DataStore.shared.loadedEvents = artEvents.reversed()
                        } else {
                            DataStore.shared.loadedEvents = artEvents
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
                            self.presentEventsLoadingFail(message: "No events")
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.presentEventsLoadingFail(message: "Failed")
                            Alerts.presentFailedDataLoadingAlert(viewController: self)
                        }
                    }
                }
            } else {
                Alerts.presentConnectionAlert(viewController: self)
            }
        }
    }
}


// MARK: - DelegateExtensions
extension EventsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataStore.loadedEvents.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let eventUrl = dataStore.loadedEvents[indexPath.row].getUrl() {
            EventsViewController.openSafariPage(withUrl: eventUrl, byController: self)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .normal, title: NSLocalizedString("Show on map", comment: "")) { (rowAction, indexPath) in
            self.dataStore.settingPresentingEvents(withEdittedRow: indexPath.row)
            self.tabBarController?.selectedIndex = 2
        }
        action.backgroundColor = #colorLiteral(red: 0.6600925326, green: 0.2217625678, blue: 0.3476891518, alpha: 1)
        return [action]
    }
}

extension EventsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventsTableViewCell else { return UITableViewCell() }
        return EventsTableViewCell.configuredCell(from: cell, for: indexPath)
    }
}
