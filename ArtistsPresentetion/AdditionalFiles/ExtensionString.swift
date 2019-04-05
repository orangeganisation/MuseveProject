//
//  ExtensionString.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 4/3/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
