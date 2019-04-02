//
//  StringConstants.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/19/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation

enum StringConstants {
    enum App {
        static let appName = "Museve"
    }
    enum AlertsStrings {
        static let cancel = NSLocalizedString("Cancel", comment: "")
        static let settings = NSLocalizedString("Settings", comment: "")
        static let ok = "Ok"
    }
    enum Search {
        static let noResults = NSLocalizedString("No results", comment: "")
        static let search = NSLocalizedString("Search", comment: "")
        static let enterName = NSLocalizedString("Enter name", comment: "")
        static let added = NSLocalizedString("Added", comment: "")
        static let removed = NSLocalizedString("Removed", comment: "")
    }
    enum ArtistEvents {
        static let events = NSLocalizedString("Events", comment: "")
        static let noEvents = NSLocalizedString("This artist has no events", comment: "")
    }
    enum Favorites {
        static let entity = "FavoriteArtist"
    }
}
