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
    @IBOutlet weak var albumArt: NSImageView!
    
    @IBOutlet weak var sampleTableView: NSTableView!
    @IBOutlet weak var sampledByTableView: NSTableView!
    
    var current: Song = Song()
    var sampleData: SampleData = SampleData()
    
    var sampleHandler: TableHandler = TableHandler()
    var sampledByHandler: TableHandler = TableHandler()
    
    let spotifyListener = SpotifyListener()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spotifyListener.delegate = self
        
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
        self.getAndSetSampleData()

        setViewWithData()
    }

}

extension MainViewController {
    func getSpotifyData() -> Song {
        return Spotify.getCurrentlyPlaying()
    }
    
    func getAndSetSampleData() {
        WhoSampled.getSampleData(self.current.track, self.current.artist) { sampleData in
            self.sampleData = sampleData

            self.sampleHandler.updateData(self.sampleData.samples)
            self.sampledByHandler.updateData(self.sampleData.sampled_by)
            
            self.sampleTableView.reloadData()
            self.sampledByTableView.reloadData()
        }
    }
    
    func setViewWithData() {
        trackTitle.stringValue = current.track
        artistTitle.stringValue = current.artist
        
        fetchImage { error, image in
            guard let image = image else { return }
            self.albumArt.image = image
        }
    }
    
    func fetchImage(completion: @escaping (Bool, NSImage?) -> ()) {
        Helpers.get(url: current.albumURL)  { data, response, error in
            DispatchQueue.main.async() {
                guard let data = data, error == nil else {
                    completion(true, nil)
                    return
                }
                completion(false, NSImage(data: data))
            }
        }
    }
    
}

extension MainViewController: SpotifyListenerDelegate {
    
    func playbackStateChanged() {
        print("spotify Updated")
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
