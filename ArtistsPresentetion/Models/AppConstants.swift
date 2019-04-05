//
//  StringConstants.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/19/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation
import UIKit

enum IntConstant {
    // MARK: - Map
    static let minSearchCharactersCount = 2
    static let regionScale = 2000
}

enum FloatConstant {
    static let cellScale: CGFloat = 0.95
}

enum StringConstant {
    // MARK: - Application
    static let appName = "Museve"
    // MARK: - Alerts
    static let cancel = "Cancel".localized()
    static let settings = "Settings".localized()
    static let ok = "Ok"
    // MARK: - Search
    static let noResults = "No results".localized()
    static let search = "Search".localized()
    static let enterName = "Enter name".localized()
    static let added = "Added".localized()
    static let removed = "Removed".localized()
    // MARK: - Events
    static let events = "Events".localized()
    static let noEvents = "This artist has no upcoming events".localized()
    // MARK: - Database Entity
    static let favoriteArtistEntity = "FavoriteArtist"
    // MARK: - ViewControllers
    static let dateViewController = "datePickerViewController"
    static let eventsViewController = "viewController"
}
