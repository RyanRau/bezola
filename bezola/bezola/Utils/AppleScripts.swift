//
//  AppleScripts.swift
//  bezola
//
//  Created by Ryan Rau on 12/27/21.
//

import Foundation

struct AppleScripts {
//  Location for apple script references  /Applications/Spotify.app/Contents/Resources/Spotify.sdef
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
