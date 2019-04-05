//
//  InternetManager.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/19/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit

final class InternetDataManager {
    
    static let shared = InternetDataManager()
    private let dataStore = DataStore.shared
    private var sessionTaskIsLoading = false
    private let scheme = "https"
    private let getArtistUrl = "rest.bandsintown.com"
    private let path = "/artists/"
    
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
    
    func getArtist(searchText: String, completion: @escaping (_ error: Error?, _ artist: Artist?) -> Void) {
        if !sessionTaskIsLoading {
            sessionTaskIsLoading = true
            var components = URLComponents()
            components.scheme = scheme
            components.host = getArtistUrl
            components.path = path + searchText
            let appID = URLQueryItem(name: "app_id", value: StringConstant.appName)
            components.queryItems = [appID]
            if let url = components.url {
                let task = URLSession.shared.dataTask(with: url) {(artistData, response, error) in
                    self.sessionTaskIsLoading = false
                    let currentSearchText = self.dataStore.currentSearchText
                    if searchText != currentSearchText && currentSearchText.count > 2 {
                        self.getArtist(searchText: currentSearchText, completion: completion)
                    } else {
                        if error != nil {
                            completion(error, nil)
                        } else {
                            if let data = artistData, let artist = try? JSONDecoder().decode(Artist.self, from: data) {
                                completion(nil, artist)
                            } else {
                                completion(nil, nil)
                            }
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    func getEvents(forArtist name: String, completion: @escaping (_ error: Error?, _ events: [Event]?) -> Void) {
        var components = URLComponents()
        components.scheme = scheme
        components.host = getArtistUrl
        components.path = path + name + "/events"
        let appID = URLQueryItem(name: "app_id", value: StringConstant.appName)
        components.queryItems = [appID]
        if let sortingDate = dataStore.eventsFilter {
            let sortingItem = URLQueryItem(name: "date", value: sortingDate)
            components.queryItems?.append(sortingItem)
        }
        if let url = components.url {
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                if error != nil {
                    completion(error, nil)
                } else {
                    if let eventsData = data, let events = try? JSONDecoder().decode([Event].self, from: eventsData) {
                        completion(nil, events)
                    } else {
                        completion(nil, nil)
                    }
                }
            }
            task.resume()
        }
    }
}
