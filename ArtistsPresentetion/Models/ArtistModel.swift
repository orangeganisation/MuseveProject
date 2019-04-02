//
//  ArtistModel.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/18/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation

struct Artist: Codable {
    
    private var id = String()
    private var name = String()
    private var thumbURL = String()
    private var mbID = String()
    private var facebookProfileURL: String?
    private var imageURL = String()
    private var trackerCount = Int()
    private var upcomingEventsCount = Int()
    private var url = String()
    
    func getName() -> String {
        return name
    }
    mutating func setName(name: String) {
        self.name = name
    }
    func getImageUrl() -> String {
        return imageURL
    }
    func getThumbUrl() -> String {
        return thumbURL
    }
    func getFacebookUrl() -> URL? {
        if let facebookProfileURL = facebookProfileURL {
            return URL(string: facebookProfileURL)
        } else {
            return nil
        }
    }
    func getUpcomingEventCount() -> Int {
        return upcomingEventsCount
    }
    mutating func setUpcomingEventsCount(count: Int) {
        self.upcomingEventsCount = count
    }
    func getID() -> String {
        return id
    }
    mutating func setId(id: String) {
        self.id = id
    }
    
    enum CodingKeys: String, CodingKey {
        case thumbURL = "thumb_url"
        case mbID = "mbid"
        case name
        case facebookProfileURL = "facebook_page_url"
        case imageURL = "image_url"
        case trackerCount = "tracker_count"
        case upcomingEventsCount = "upcoming_event_count"
        case id
        case url
    }
}
