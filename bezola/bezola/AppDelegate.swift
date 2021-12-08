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
  
        view.set()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        view.exit()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

}
