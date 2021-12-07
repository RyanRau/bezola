//
//  Song.swift
//  bezola
//
//  Created by Ryan Rau on 12/6/21.
//

import Foundation

class Song: Codable{
    public let track: String
    public let artist: String
    public let year: String = "0000"
    
    init(_ input: String) {
        let split = input.split(separator: "%").map(String.init)
        
        self.track = split[0]
        self.artist = split[1]
    }
    
    init() {
        self.track = "No track playing"
        self.artist = "No artist playing"
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
