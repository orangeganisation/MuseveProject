//
//  ArtistModel.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/18/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation

struct Artist: Codable {
    
    var id = ""
    var name = ""
    private var url = ""
    private var thumbURL: String?
    var mbID = ""
    private var facebookProfileURL: String?
    private var imageURL = ""
    var trackerCount = 0
    var upcomingEventsCount = 0
    
    func getUrl() -> URL? {
        return URL(string: url)
    }
    
    func getThumbUrl() -> URL? {
        if let thumbUrl = thumbURL {
            return URL(string: thumbUrl)
        } else {
            return nil
        }
    }
    
    func getFacebookUrl() -> URL? {
        if let facebookProfileUrl = facebookProfileURL {
            return URL(string: facebookProfileUrl)
        } else {
            return nil
        }
    }
    
    func getImageUrl() -> URL? {
        return URL(string: imageURL)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, url
        case thumbURL = "thumb_url"
        case mbID = "mbid"
        case facebookProfileURL = "facebook_page_url"
        case imageURL = "image_url"
        case trackerCount = "tracker_count"
        case upcomingEventsCount = "upcoming_event_count"
    }
}
