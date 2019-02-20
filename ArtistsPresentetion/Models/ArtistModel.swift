//
//  ArtistModel.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/18/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation

class Artist: Codable{
    private var thumb_url = String()
    private var mbid = String()
    private var facebook_page_url = String()
    private var image_url = String()
    private var name = String()
    private var id = String()
    private var tracker_count = Int()
    private var upcoming_event_count = Int()
    private var url = String()
    
    func getName() -> String {
        return self.name
    }
    func getImageUrl() -> String {
        return self.image_url
    }
    func getThumbUrl() -> String {
        return self.thumb_url
    }
    func getFacebookPage() -> String? {
        if self.facebook_page_url.isEmpty{
            return nil
        } else {
            return self.facebook_page_url
        }
    }
    func getUpcomingEventCount() -> Int {
        return self.upcoming_event_count
    }
    func getURL() -> String {
        return self.url
    }
}
