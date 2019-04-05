//
//  SafariManager.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 4/3/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation
import SafariServices

final class SafariManager {
    
    static func openPageInBrowser(withUrl url: URL) {
        let safari = SFSafariViewController(url: url)
        safari.preferredBarTintColor = #colorLiteral(red: 0.1660079956, green: 0.1598443687, blue: 0.1949053109, alpha: 1)
        if let window = UIApplication.shared.keyWindow, let topViewController = window.rootViewController {
            topViewController.present(safari, animated: true)
        }
    }
}
