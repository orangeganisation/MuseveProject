//
//  EventsViewController.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/22/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import UIKit

final class EventsViewController: UIViewController {
    
    // MARK: - Vars & Lets
    private let dataStore = DataStore.shared
    private let internetManager = InternetDataManager.shared
    
    // MARK: - Outlets
    @IBOutlet private weak var haveNoEventsLabel: UILabel!
    @IBOutlet private weak var eventsTableView: UITableView!
    @IBOutlet private weak var loadingDataSpinner: UIActivityIndicatorView!
    @IBOutlet private weak var eventsFilterSegment: UISegmentedControl! {
        didSet {
            for index in eventsFilterSegment.subviews.indices {
                if let title = eventsFilterSegment.titleForSegment(at: index) {
                    eventsFilterSegment.setTitle(title.localized(), forSegmentAt: index)
                }
            }
        }
    }
    @IBOutlet private weak var navigationBar: UINavigationItem! {
        didSet {
            if let title = navigationBar.title {
                navigationBar.title = title.localized()
            }
        }
    }
    
    
    
    // MARK: - Actions
    @IBAction func changeFilterInSegment(_ sender: UISegmentedControl) {
        eventsFilterSegment.alpha = 1
        switch eventsFilterSegment.selectedSegmentIndex {
        case 0: dataStore.eventsFilter = "upcoming"
        case 1: dataStore.eventsFilter = "past"
        default: dataStore.eventsFilter = "all"
        }
        loadEvents()
    }
    
    @IBAction func sortEventsByDate(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Events", bundle: nil)
        if let dateViewController = storyboard.instantiateViewController(withIdentifier: StringConstant.dateViewController) as? DateViewController {
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
        dataStore.resetEventsFilter()
        if dataStore.presentingOnMapArtist.upcomingEventsCount == 0 {
            dataStore.eventsFilter = "all"
            eventsFilterSegment.selectedSegmentIndex = 2
        } else {
            eventsFilterSegment.selectedSegmentIndex = 0
        }
        loadEvents()
    }
    
    // MARK: - MyTools
    func presentEvents() {
        DispatchQueue.main.async {
            self.eventsTableView.isHidden = false
            self.haveNoEventsLabel.isHidden = true
            UIView.animate(withDuration: 0.5, animations: {
                self.eventsTableView.alpha = 1.0
            })
            self.eventsTableView.reloadData()
        }
    }
    
    func showLoading() {
        haveNoEventsLabel.isHidden = true
        eventsTableView.isHidden = true
        loadingDataSpinner.startAnimating()
    }
    
    func presentEventsLoadingFail(message: String) {
        haveNoEventsLabel.text = message.localized()
        eventsTableView.isHidden = true
        haveNoEventsLabel.isHidden = false
    }
    
    func loadEvents() {
        UIView.animate(withDuration: 0.5) {
            self.eventsTableView.alpha = 0
        }
        showLoading()
        if let named = dataStore.presentingOnMapArtist.name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            let eventsFilter = dataStore.eventsFilter
            if internetManager.isConnectedToNetwork() {
                internetManager.getEvents(forArtist: named) { (error, artEvents) in
                    DispatchQueue.main.async {
                        self.loadingDataSpinner.stopAnimating()
                    }
                    if error != nil {
                        DispatchQueue.main.async {
                            self.presentEventsLoadingFail(message: "Failed")
                            Alerts.presentFailedDataLoadingAlert()
                        }
                    } else if let artEvents = artEvents, artEvents.count != 0 {
                        self.dataStore.loadedEvents = eventsFilter != "upcoming" && eventsFilter != nil ? artEvents.reversed() : artEvents
                        self.presentEvents()
                    } else if artEvents != nil {
                        DispatchQueue.main.async {
                            self.presentEventsLoadingFail(message: "No events")
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.presentEventsLoadingFail(message: "Failed")
                            Alerts.presentFailedDataLoadingAlert()
                        }
                    }
                }
            } else {
                Alerts.presentConnectionAlert()
            }
        }
    }
}


// MARK: - DelegateExtensions
extension EventsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataStore.loadedEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventsTableViewCell", for: indexPath) as? EventsTableViewCell else { return UITableViewCell() }
        let event = dataStore.loadedEvents[indexPath.row]
        cell.configureCell(at: indexPath, byData: event)
        return cell
    }
}

extension EventsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let eventUrl = dataStore.loadedEvents[indexPath.row].getUrl() {
            SafariManager.openPageInBrowser(withUrl: eventUrl)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .normal, title: "Show on map".localized()) { (rowAction, indexPath) in
            self.dataStore.settingPresentingEvents(withEdittedRow: indexPath.row)
            (self.tabBarController as? MainTabBarViewController)?.switchToMapController()
        }
        action.backgroundColor = #colorLiteral(red: 0.6600925326, green: 0.2217625678, blue: 0.3476891518, alpha: 1)
        return [action]
    }
}
