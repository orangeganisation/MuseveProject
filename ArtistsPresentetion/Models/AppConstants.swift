//
//  StringConstants.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/19/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation

struct StringConstants {
    struct App {
        static let appName = "Museve"
    }
    struct Urls {
        static let scheme = "https"
        static let getArtistUrl = "rest.bandsintown.com"
        static let path = "/artists/"
    }
    struct AlertsStrings {
        static let cancel = NSLocalizedString("Cancel", comment: "")
        static let settings = NSLocalizedString("Settings", comment: "")
        static let ok = "Ok"
        static let internetProblems = NSLocalizedString("There is a problem with internet connection. Please, turn ON cellular or connect to WiFi.", comment: "")
        static let locationFailed = NSLocalizedString("Turn On Location Services to allow \"Museve\" to determine Your location:\nSettings->Privacy->Location Services", comment: "")
        static let dataLoadingFailed = NSLocalizedString("Failed to load data. Please, try again later.", comment: "")
    }
    struct Search {
        static let noResults = NSLocalizedString("No results", comment: "")
        static let search = NSLocalizedString("Search", comment: "")
        static let enterName = NSLocalizedString("Enter name", comment: "")
        static let added = NSLocalizedString("Added", comment: "")
        static let removed = NSLocalizedString("Removed", comment: "")
    }
    struct ArtistEvents {
        static let events = NSLocalizedString("Events", comment: "")
        static let noEvents = NSLocalizedString("This artist has no events", comment: "")
    }
}
