//
//  Song.swift
//  bezola
//
//  Created by Ryan Rau on 12/6/21.
//

import Foundation
import SpotifyWebAPI

struct Song {
    public let track: String
    public let artist: String
    
    public let albumURL: String
    public let year: String
    
    public var spotifyTrack: Track? = nil
    public var isPlaceholder: Bool
    
    init(_ input: String) {
        let split = input.split(separator: "%").map(String.init)
        
        self.track = split.count > 0 ? split[0] : "Failed to retrieve track"
        self.artist = split.count > 1 ? split[1] : "Failed to retrieve artist"
        self.albumURL = split.count > 2 ? split[2] : "Failed to retrieve album art url"
        
        self.year = "N/A"
        
        self.isPlaceholder = false
    }
    
    init(isPlaceholder: Bool = false) {
        self.track = "No track playing"
        self.artist = "No artist playing"
        
        self.albumURL = "N/A"
        self.year = "N/A"
        
        self.isPlaceholder = isPlaceholder
    }
}

extension Song: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case track, artist, year, albumURL
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        track = try container.decode(String.self, forKey: .track)
        artist = try container.decode(String.self, forKey: .artist)
        year = try container.decode(String.self, forKey: .year)
        albumURL = try container.decode(String.self, forKey: .albumURL)
        isPlaceholder = false
    }
    
}
