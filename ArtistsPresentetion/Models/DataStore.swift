//
//  DataStore.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 3/28/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation

final class DataStore {
    
    static var shared = DataStore()
    
    // MARK: - Search
    var currentFoundArtist: Artist?
    var currentSearchText = String()
    
    // MARK: - Map
    var presentingOnMapArtist = Artist()
    var needSetCenterMap = true
    var presentingEvents = [Event]()

    // MARK: - Favorites
    var multiplySelectionIsAllowed = false
    
    // MARK: - Events
    var loadedEvents = [Event]()
    var eventsFilter: String?
    var shouldUpdateEvents = false
    
    // MARK: - My tools
    func settingPresentingEvents(withEdittedRow index: Int) {
        let presentingEvents = DataStore.shared.presentingEvents
        if presentingEvents.first?.getArtistID() != DataStore.shared.loadedEvents[index].getArtistID() {
            DataStore.shared.presentingEvents.removeAll()
        }
        DataStore.shared.presentingEvents.append(DataStore.shared.loadedEvents[index])
        DataStore.shared.needSetCenterMap = true
    }
    
    func resetEventsFilter() {
        DataStore.shared.eventsFilter = nil
    }
    
    func setEventsFilterDate(fromDate: Date, toDate: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fromDate = dateFormatter.string(from: fromDate)
        let toDate = dateFormatter.string(from: toDate)
        DataStore.shared.eventsFilter = (fromDate + "," + toDate).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
    }
    
    func isEventsFilterSettedBySegment() -> Bool {
        if DataStore.shared.eventsFilter == "upcomimg" ||
            DataStore.shared.eventsFilter == "past" ||
            DataStore.shared.eventsFilter == "all" ||
            DataStore.shared.eventsFilter == nil {
            return true
        } else {
            return false
        }
    }
}
