//
//  DataStore.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 3/28/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation

final class DataStore {
    
    enum EventsFilter {
        case none
        case upcoming
        case past
        case all
        case date(fromDate: Date, toDate: Date)
        
        init(){
            self = .none
        }
    }
    static var shared = DataStore()
    
    // MARK: - Search
    var currentFoundArtist: Artist?
    var currentSearchText = ""
    
    // MARK: - Map
    var presentingOnMapArtist = Artist()
    var needSetCenterMap = true
    var presentingEvents = [Event]()

    // MARK: - Events
    var loadedEvents = [Event]()
    var eventsFilter = EventsFilter()
    var shouldUpdateEvents = false
    
    // MARK: - My tools
    func settingPresentingEvents(withEdittedRow index: Int) {
        if presentingEvents.first?.artistID != loadedEvents[index].artistID {
            presentingEvents.removeAll()
        }
        presentingEvents.append(loadedEvents[index])
        needSetCenterMap = true
    }
    
    func setPresentingOnMapArtist(name: String, id: String, upcomingEventsCount: Int) {
        presentingOnMapArtist.name = name
        presentingOnMapArtist.id = id
        presentingOnMapArtist.upcomingEventsCount = upcomingEventsCount
    }
    
    func resetCurrentFoundArtist() {
        currentFoundArtist = nil
    }
    
    func resetEventsFilter() {
        eventsFilter = .none
    }

    func getFilterDate() -> String? {
        switch eventsFilter {
        case .all: return "all"
        case .past: return "past"
        case .upcoming: return "upcoming"
        case .date(fromDate: let fromDate, toDate: let toDate):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let fromDate = dateFormatter.string(from: fromDate)
            let toDate = dateFormatter.string(from: toDate)
            return (fromDate + "," + toDate).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        default:
            return nil
        }
    }
    
    func isEventsFilterSettedBySegment() -> Bool {
        switch eventsFilter {
        case .all, .past, .upcoming, .none: return true
        default: return false
        }
    }
}
