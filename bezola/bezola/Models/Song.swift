//
//  Song.swift
//  bezola
//
//  Created by Ryan Rau on 12/6/21.
//

import Foundation

struct Song {
    public let track: String
    public let artist: String
    
    public let albumURL: String
    public let year: String
    
    init(_ input: String) {
        let split = input.split(separator: "%").map(String.init)
        
        self.track = split[0]
        self.artist = split[1]
        self.albumURL = split[2]
        
        self.year = "N/A"
    }
    
    init() {
        self.track = "No track playing"
        self.artist = "No artist playing"
        
        self.albumURL = "N/A"
        self.year = "N/A"
    }
    
    func getTrack() -> String {
        return self.track
    }
    
    func getArtist() -> String {
        return self.artist
    }
    
    func getYear() -> String {
        return self.year
    }
}

extension Song: Decodable {
    private enum CodingKeys: String, CodingKey {
        case track, artist, year
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        track = try container.decode(String.self, forKey: .track)
        artist = try container.decode(String.self, forKey: .artist)
        year = try container.decode(String.self, forKey: .year)
        
        albumURL = "N/A"
    }
    
}
