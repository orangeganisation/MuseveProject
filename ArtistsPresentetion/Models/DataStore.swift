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
    var currentSearchText = ""
    
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
        if presentingEvents.first?.artistID != loadedEvents[index].artistID {
            presentingEvents.removeAll()
        }
        presentingEvents.append(loadedEvents[index])
        needSetCenterMap = true
    }
    
    func resetCurrentFoundArtist() {
        currentFoundArtist = nil
    }
    
    func resetEventsFilter() {
        eventsFilter = nil
    }
    
    func setEventsFilterDate(fromDate: Date, toDate: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fromDate = dateFormatter.string(from: fromDate)
        let toDate = dateFormatter.string(from: toDate)
        eventsFilter = (fromDate + "," + toDate).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
    }
    
    func isEventsFilterSettedBySegment() -> Bool {
        return eventsFilter == "upcomimg" || eventsFilter == "past" || eventsFilter == "all" || eventsFilter == nil ? true : false
    }
}
