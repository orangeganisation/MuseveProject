//
//  InternetManager.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/19/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration
import SafariServices

class InternetDataManager {
    
    private var sessionTaskIsLoading = false
    static let shared = InternetDataManager()
    
    public func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        if flags.isEmpty {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    static func openSafariPage(withUrl url: URL, byController viewController: UIViewController) {
        let safari = SFSafariViewController(url: url)
        safari.preferredBarTintColor = #colorLiteral(red: 0.1660079956, green: 0.1598443687, blue: 0.1949053109, alpha: 1)
        viewController.present(safari, animated: true, completion: nil)
    }
    
    func getArtist(viewController: UIViewController, searchText: String, completion: @escaping (_ error: Error?,_ artist: Artist?) -> Void) {
        if !sessionTaskIsLoading {
            sessionTaskIsLoading = true
            if self.isConnectedToNetwork(){
                var components = URLComponents()
                components.scheme = StringConstants.Urls.scheme
                components.host = StringConstants.Urls.getArtistUrl
                components.path = StringConstants.Urls.path + searchText
                let appID = URLQueryItem(name: "app_id", value: StringConstants.App.appName)
                components.queryItems = [appID]
                if let url = components.url {
                    let task = URLSession.shared.dataTask(with: url) {(artistData, response, error) in
                        self.sessionTaskIsLoading = false
                        if searchText != DataStore.Search.currentSearchText && DataStore.Search.currentSearchText.count > 2 {
                            self.getArtist(viewController: viewController, searchText: DataStore.Search.currentSearchText, completion: completion)
                        } else {
                            if error != nil {
                                completion(error, nil)
                            } else {
                                if let data = artistData{
                                    if let artist = try? JSONDecoder().decode(Artist.self, from: data) {
                                        completion(nil, artist)
                                    } else {
                                        completion(nil, nil)
                                    }
                                }
                            }
                        }
                    }
                    task.resume()
                }
            } else {
                Alerts.presentConnectionAlert(viewController: viewController)
            }
        }
    }
    
    func getEvents(forArtist name: String, forDate date: String?, viewController: UIViewController, completion: @escaping (_ error: Error?,_ events: [Event]?) -> Void) {
        if self.isConnectedToNetwork() {
            var components = URLComponents()
            components.scheme = StringConstants.Urls.scheme
            components.host = StringConstants.Urls.getArtistUrl
            components.path = StringConstants.Urls.path + name + "/events"
            let appID = URLQueryItem(name: "app_id", value: StringConstants.App.appName)
            components.queryItems = [appID]
            if let sortingDate = date {
               let sortingItem = URLQueryItem(name: "date", value: sortingDate)
                components.queryItems?.append(sortingItem)
            }
            if let url = components.url {
                let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                    if error != nil {
                        completion(error, nil)
                    } else {
                        if let eventsData = data {
                            do {
                                let events = try JSONDecoder().decode([Event].self, from: eventsData)
                                completion(nil, events)
                            } catch {
                                print(error)
                                completion(nil, nil)
                            }
                        }
                    }
                }
                task.resume()
            }
        } else {
            Alerts.presentConnectionAlert(viewController: viewController)
        }
    }
}
