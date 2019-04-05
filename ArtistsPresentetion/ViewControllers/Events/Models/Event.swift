//
//  File.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/22/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation

struct Event: Codable {
    
    let id: String
    private let url: String
    let datetime: String
    let description: String?
    let offers: [Offer]?
    let artistID: String
    let onSaleDatetime: String?
    let situation: VenueData?
    let lineUp: [String]?
    
    func getUrl() -> URL? {
        return URL(string: url)
    }
    
    func getParticipants() -> String? {
        return lineUp?.joined(separator: "\n")
    }
    
    enum CodingKeys: String, CodingKey {
        case id, url, datetime, description, offers
        case artistID = "artist_id"
        case onSaleDatetime = "on_sale_datetime"
        case situation = "venue"
        case lineUp = "lineup"
    }
}

struct VenueData: Codable {
    
    let country: String
    let city: String
    let latitude: String?
    let name: String
    let region: String?
    let longitude: String?
}

struct Offer: Codable {
    
    let type: String?
    private let url: String?
    let status: String?
    
    func getUrl() -> URL? {
        if let url = url {
            return URL(string: url)
        }
        return nil
    }
}
