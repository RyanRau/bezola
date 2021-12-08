//
//  SpotifyListener.swift
//  bezola
//
//  Created by Ryan Rau on 12/6/21.
//  With inspiration from https://github.com/laaksomavrick/menu-bar-for-spotify
//

import Foundation

struct AppleScripts {
    static let currentlyPlaying =
    """
        tell application "Spotify"
            set currentArtist to artist of current track as string
            set currentTrack to name of current track as string
            set currentAlbumUrl to artwork url of current track as string
            return currentTrack & "%" & currentArtist & "%" & currentAlbumUrl
        end tell
    """
    
    static let isRunning =
    """
        tell application "System Events"
            set ids to bundle identifier of every application process
            if ids contains "com.spotify.client" then
                return true
            else
                return false
            end if
        end tell
    """
    
    
    static let playerState =
    """
        tell application "Spotify"
            return player state as string
        end tell
    """
    
    static let togglePlayerState =
    """
        tell application "Spotify"
            playpause
        end tell
    """
}

class Spotify {
    static func isRunning() -> Bool {
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: AppleScripts.isRunning) {
            let output = scriptObject.executeAndReturnError(&error)
            
            if error != nil {
                print("Error executing apple script")
                print(error as Any)
                return false
            }
            
            if let data = output.stringValue, let value = Bool(data) {
                return value
            }
        }
        return false
    }
    

    static func getCurrentlyPlaying() -> Song {
        guard isRunning() == true else { return Song() }
        
        var error: NSDictionary?
        
        if let scriptObject = NSAppleScript(source: AppleScripts.currentlyPlaying) {
            let output = scriptObject.executeAndReturnError(&error)
            
            if error != nil {
                print("Error executing apple script")
                print(error as Any)
                return Song()
            }
            
            if let data = output.stringValue {
                return Song(data)
            }
        }
        return Song()
    }
}

