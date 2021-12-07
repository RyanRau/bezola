//
//  AppDelegate.swift
//  bezola
//
//  Created by Ryan Rau on 12/6/21.
//

import Cocoa
import PythonKit


@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let view = PopoverController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Removes app from dock
        NSApp.setActivationPolicy(.regular)
        NSApp.setActivationPolicy(.accessory)
        NSApp.setActivationPolicy(.prohibited)
        
        let song = Spotify.getCurrentlyPlaying()
        print(song.track, song.artist)
  
        view.set()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        view.exit()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

}


// CODE DUMP
//func applicationDidFinishLaunching(_ aNotification: Notification) {
//    // Insert code here to initialize your application
//    let song = Spotify.getCurrentlyPlaying()
//    print(song.artist, song.track)
//
//    let who = WhoSampled.getSampleData(song.track, song.artist)
//    print(who)
//
//////        PythonLibrary.useVersion(395)
////        let sys = try Python.import("sys")
////
////        print("Python \(sys.version_info.major).\(sys.version_info.minor)")
////        print("Python Version: \(sys.version)")
////        print("Python Encoding: \(sys.getdefaultencoding().upper())")
////
////        sys.path.append("/Users/ryanrau/Documents/Code/bezola/who_sampled_scraper/")
////        let example = Python.import("scraper")
////        example.ping()
////
//////        let result = example.get_data("Kanye West", "I Wonder")
////        let result = example.get_data(song.artist, song.track)
////        print(result)
//}
