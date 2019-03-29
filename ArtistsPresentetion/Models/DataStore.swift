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
    var artistIsInDataBase = false
    var currentSearchText = String()
    
    // MARK: - Map
    var currentEventsArtist: (name: String, upcominIvents: Int, id: String)?
    var needSetCenterMap = true
    var presentingEvents = [Event]()

    // MARK: - Favorites
    var multiplySelectionIsAllowed = false
    
    // MARK: - Events
    var events = [Event]()
    var eventsFilter: String?
    var shouldUpdateEvents = false
}
