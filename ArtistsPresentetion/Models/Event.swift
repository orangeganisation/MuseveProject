//
//  File.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/22/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation

class Event: Codable {
    
    private var id: String?
    private var artist_id: String?
    private var url: String?
    private var on_sale_datetime: String?
    private var datetime: String?
    private var description: String?
    private var venue: VenueData?
    private var lineup: [String]?
    private var offers: [Offer]?
    
    func getID() -> String? {
        return self.id
    }
    func getArtistID() -> String? {
        return self.artist_id
    }
    func getUrl() -> String? {
        return self.url
    }
    func getOnSaleDatetime() -> String? {
        return self.on_sale_datetime
    }
    func getDatetime() -> String? {
        return self.datetime
    }
    func getDescription() -> String? {
        return self.description
    }
    func getVenue() -> VenueData? {
        return self.venue
    }
    func getLineup() -> [String]? {
        return self.lineup
    }
    func getOffers() -> [Offer]? {
        return self.offers
    }
}

class VenueData: Codable {
    
    private var country: String?
    private var city: String?
    private var latitude: String?
    private var name: String?
    private var region: String?
    private var longitude: String?
    
    func getCountry() -> String? {
        return self.country
    }
    func getCity() -> String? {
        return self.city
    }
    func getLatitude() -> String? {
        return self.latitude
    }
    func getName() -> String? {
        return self.name
    }
    func getRegion() -> String? {
        return self.region
    }
    func getLongtitude() -> String? {
        return self.longitude
    }
}

class Offer: Codable {
    
    private var type: String?
    private var url: String?
    private var status: String?
    
    func getType() -> String? {
        return self.type
    }
    func getUrl() -> String? {
        return self.url
    }
    func getStatus() -> String? {
        return self.status
    }
}
