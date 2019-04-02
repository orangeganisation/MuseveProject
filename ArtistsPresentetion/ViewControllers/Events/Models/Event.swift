//
//  File.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/22/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation

struct Event: Codable {
    
    private var id: String?
    private var artistID: String?
    private var url: String?
    private var onSaleDatetime: String?
    private var datetime: String?
    private var description: String?
    private var situation: VenueData?
    private var lineUp: [String]?
    private var offers: [Offer]?
    
    func getID() -> String? {
        return id
    }
    func getArtistID() -> String? {
        return artistID
    }
    func getUrl() -> URL? {
        if let url = url {
            return URL(string: url)
        } else {
            return nil
        }
    }
    func getOnSaleDatetime() -> String? {
        return onSaleDatetime
    }
    func getDatetime() -> String? {
        return datetime
    }
    func getDescription() -> String? {
        return description
    }
    func getVenue() -> VenueData? {
        return situation
    }
    func getLineup() -> [String]? {
        return lineUp
    }
    func getOffers() -> [Offer]? {
        return offers
    }
    
    func getParticipants() -> String {
        var participants = ""
        var shouldEnter = true
        if let lineUp = lineUp {
            for participant in lineUp {
                if shouldEnter {
                    participants.append(participant)
                    shouldEnter = false
                } else {
                    participants.append("\n\(participant)")
                }
            }
        }
        return participants
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case artistID = "artist_id"
        case url
        case onSaleDatetime = "on_sale_datetime"
        case datetime
        case description
        case situation = "venue"
        case lineUp = "lineup"
        case offers
    }
}

struct VenueData: Codable {
    
    private var country: String?
    private var city: String?
    private var latitude: String?
    private var name: String?
    private var region: String?
    private var longitude: String?
    
    func getCountry() -> String? {
        return country
    }
    func getCity() -> String? {
        return city
    }
    func getLatitude() -> String? {
        return latitude
    }
    func getName() -> String? {
        return name
    }
    func getRegion() -> String? {
        return region
    }
    func getLongtitude() -> String? {
        return longitude
    }
}

struct Offer: Codable {
    
    private var type: String?
    private var url: String?
    private var status: String?
    
    func getType() -> String? {
        return type
    }
    func getUrl() -> String? {
        return url
    }
    func getStatus() -> String? {
        return status
    }
}
