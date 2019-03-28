//
//  DataStore.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 3/28/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation

struct DataStore {
    struct Search {
        static var currentFoundArtist: Artist?
        static var artistIsInDataBase = false
        static var currentSearchText = String()
    }
    struct Map {
        static var currentEventsArtistName: String?
        static var currentEventsArtistId: String?
        static var needSetCenterMap = true
        static var presentingEvents = [Event]()
    }
    struct Favorites {
        static var multiplySelectionIsAllowed = false
    }
    struct Events {
        static var events = [Event]()
        static var eventsFilter: String?
        static var shouldUpdateEvents = false
    }
}
