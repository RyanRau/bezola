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
    @IBOutlet weak var sampleTableView: NSTableView!
    @IBOutlet weak var sampledByTableView: NSTableView!
    
    var current: Song = Song()
    var sampleData: SampleData = SampleData()
    
    var sampleHandler: TableHandler = TableHandler()
    var sampledByHandler: TableHandler = TableHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sampleTableView.headerView = nil
        sampledByTableView.headerView = nil
        
        self.sampleHandler.updateData(self.sampleData.samples)
        sampleTableView.delegate = self.sampleHandler
        sampleTableView.dataSource = self.sampleHandler
        
        self.sampledByHandler.updateData(self.sampleData.samples)
        sampledByTableView.delegate = self.sampledByHandler
        sampledByTableView.dataSource = self.sampledByHandler
    }
    
    override func viewWillAppear() {
        self.current = getSpotifyData()
        self.sampleData = getSampleData()

        self.sampleHandler.updateData(self.sampleData.samples)
        self.sampledByHandler.updateData(self.sampleData.sampled_by)
        
//        self.sampleData = WhoSampled.getSampleData("I Wonder", "Kanye West")
        
        sampleTableView.reloadData()
        sampledByTableView.reloadData()
        
        setViewWithData()
    }

}

extension MainViewController {
    func getSpotifyData() -> Song {
        return Spotify.getCurrentlyPlaying()
    }
    
    func getSampleData() -> SampleData {
        return WhoSampled.getSampleData(current.track, current.artist)
    }
    
    func setViewWithData() {
        trackTitle.stringValue = current.track
        artistTitle.stringValue = current.artist
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
