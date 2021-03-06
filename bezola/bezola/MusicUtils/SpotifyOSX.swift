//
//  SpotifyOSX.swift
//  bezola
//
//  Created by Ryan Rau on 12/28/21.
//  With inspiration from https://github.com/laaksomavrick/menu-bar-for-spotify
//

import Cocoa

// Interaction with the system's instance of Spotify rather than the API
class SpotifyOSX {
    static func isRunning() -> Bool {
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: AppleScripts.isRunning) {
            let output = scriptObject.executeAndReturnError(&error)
            
            if error != nil {
                print("APPLE SCRIPT ERROR: \(error as Any)")
                return false
            }
            
            if let data = output.stringValue, let value = Bool(data) {
                return value
            }
        }
        return false
    }
    
    static func getPlaybackState() -> Bool {
        guard isRunning() == true else { return false }
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: AppleScripts.playerState) {
            let output = scriptObject.executeAndReturnError(&error)
            
            if error != nil {
                print("APPLE SCRIPT ERROR: \(error as Any)")
                return false
            }
            
            if let data = output.stringValue {
                return (data == "playing" ? true : false)
            }
        }
        return false
    }
    
    static func togglePlaybackState() {
        guard isRunning() == true else { return }
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: AppleScripts.togglePlayerState) {
            scriptObject.executeAndReturnError(&error)
            
            if error != nil {
                print("APPLE SCRIPT ERROR: \(error as Any)")
            }
        }
    }
    
    static func getCurrentlyPlaying() -> Song {
        guard isRunning() == true else { return Song() }
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: AppleScripts.currentlyPlaying) {
            let output = scriptObject.executeAndReturnError(&error)
            
            if error != nil {
                print("APPLE SCRIPT ERROR: \(error as Any)")
                return Song()
            }
            
            if let data = output.stringValue {
                return Song(data)
            }
        }
        return Song()
    }
    
    static func playTrack(_ uri: String) {
        guard isRunning() == true else {
            print("Spotify is not runinng")
            return
        }
        
        let script = """
            tell application "Spotify"
                play track "\(uri)"
            end tell
        """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
            
            if error != nil {
                print("APPLE SCRIPT ERROR: \(error as Any)")
                return
            }
        }
    }
    
    static func openSpotifyTrack(uri: String) {
        NSWorkspace.shared.open(URL(string: uri)!)
    }
}
