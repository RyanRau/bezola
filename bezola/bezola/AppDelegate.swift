//
//  AppDelegate.swift
//  bezola
//
//  Created by Ryan Rau on 12/6/21.
//

import Cocoa
import PythonKit
import Combine
import SpotifyWebAPI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let spotify = Spotify()
    let view = PopoverController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Removes app from dock
        NSApp.setActivationPolicy(.accessory)
        
        view.set(self.spotify)
    }
    

    func applicationWillTerminate(_ aNotification: Notification) {
        view.exit()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    // handles redirect URL from Spotify Auth
    func application(_ application: NSApplication, open urls: [URL]) {
        guard urls[0].scheme == self.spotify.loginCallbackURL.scheme else {
            print("Invalid Scheme for Spotify redirect URL")
            return
        }

        self.spotify.onCallBack(urls[0])
    }
}
