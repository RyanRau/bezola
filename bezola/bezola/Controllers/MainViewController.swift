//
//  ViewController.swift
//  bezola
//
//  Created by Ryan Rau on 12/6/21.
//

import Cocoa

class MainViewController: NSViewController {
    
    @IBOutlet weak var trackTitle: NSTextField!
    @IBOutlet weak var artistTitle: NSTextField!
    
    var current: Song = Song()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        self.current = getSpotifyData()
        setViewWithData()
    }

}

extension MainViewController {
    func getSpotifyData() -> Song {
        return Spotify.getCurrentlyPlaying()
    }
    
    func setViewWithData() {
        trackTitle.stringValue = current.track
//        artistTitle.stringValue = current.artist
    }
    
}

extension MainViewController {
    static func freshController() -> MainViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = "MainViewController"
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(identifier)) as? MainViewController else {
            fatalError("Can't find view from storyboard")
        }
        return viewcontroller
    }
}
