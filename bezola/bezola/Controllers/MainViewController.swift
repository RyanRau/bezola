//
//  ViewController.swift
//  bezola
//
//  Created by Ryan Rau on 12/6/21.
//

import Cocoa
import WebKit

class MainViewController: NSViewController {
    @IBOutlet weak var trackTitle: NSTextField!
    @IBOutlet weak var artistTitle: NSTextField!
    @IBOutlet weak var albumArt: NSImageView!
    
    @IBOutlet weak var settingsButton: NSButton!
    @IBOutlet weak var playbackStateButton: NSButton!
    
    @IBOutlet weak var whoSampledTabView: NSTabView!
    @IBOutlet weak var sampleTableView: NSTableView!
    @IBOutlet weak var sampledByTableView: NSTableView!
    
    var current: Song = Song()
    var whoSampledData: WhoSampledData = WhoSampledData()
    
    var sampleHandler: TableHandler = TableHandler()
    var sampledByHandler: TableHandler = TableHandler()
    
    var spotify: Spotify = Spotify(isPlaceholder: true) // inits as placeholder class; avoids optional unwrapping
    let spotifyListener = SpotifyListener()
    
    var spotifyAuthStatus = false
    var isPlaying = false

    var popoverControllerRef: PopoverController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        spotifyListener.delegate = self
        configHoverAreas()
        
        self.configTables()
        self.getAndSetData()
    }
    
    override func viewWillAppear() {
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == "SettingsSegue" {
            let settingsController = segue.destinationController as! SettingsViewController
            settingsController.spotify = self.spotify
        }
        
        self.popoverControllerRef?.hidePopover(nil)
    }
    
    override func mouseEntered(with event: NSEvent) {
        if let owner = event.trackingArea?.owner as? NSControl {
            let id : String = owner.identifier!.rawValue

            switch id {
                case self.albumArt.identifier!.rawValue:
                    self.togglePlaybackStateButton(isActive: true)
                default:
                    return
            }
        }
    }
        
    override func mouseExited(with event: NSEvent) {
        if let owner = event.trackingArea?.owner as? NSControl {
            let id : String = owner.identifier!.rawValue

            switch id {
                case self.albumArt.identifier!.rawValue:
                    self.togglePlaybackStateButton(isActive: false)
                default:
                    return
            }
        }
    }
    
    @IBAction func togglePlaybackState(_ sender: Any) {
        SpotifyOSX.togglePlaybackState()
    }
}

extension MainViewController {
    func configHoverAreas() {
        self.albumArt.addTrackingArea(Helpers.createTrackingArea(control: self.albumArt))
    }
    
    func configTables(){
        sampleTableView.headerView = nil
        sampledByTableView.headerView = nil
        
        sampleHandler.onAddToQueue = { self.addToQueue($0, completion: $1) }
        sampledByHandler.onAddToQueue = { self.addToQueue($0, completion: $1) }
        
        self.sampleHandler.updateData(self.whoSampledData.samples)
        sampleTableView.delegate = self.sampleHandler
        sampleTableView.dataSource = self.sampleHandler
        
        self.sampledByHandler.updateData(self.whoSampledData.samples)
        sampledByTableView.delegate = self.sampledByHandler
        sampledByTableView.dataSource = self.sampledByHandler
    }

    func getAndSetData(){
        self.isPlaying = SpotifyOSX.getPlaybackState()
        playbackStateButton.image = NSImage(
            systemSymbolName: (isPlaying ? "pause" : "play"),
            accessibilityDescription: nil
        )
        
        self.current = SpotifyOSX.getCurrentlyPlaying()
        
        trackTitle.stringValue = current.track
        artistTitle.stringValue = current.artist
        
        fetchImage { error, image in
            guard let image = image else { return }

            self.albumArt.image = image
        }
        
        self.getAndSetWhoSampledData()
    }
    
    func getAndSetWhoSampledData() {
        WhoSampled.getSampleData(self.current.track, self.current.artist) { data in
            self.spotify.completeWhoSampledData(data: data) { completeData in
                self.whoSampledData = completeData

                self.updateTables(data: completeData)
            }
        }
    }
    
    func updateTables(data: WhoSampledData) {
        var data = data
        
        if data.samples.isEmpty {
            data.samples.append(Song(isPlaceholder: true))
        }
        if data.sampled_by.isEmpty {
            data.sampled_by.append(Song(isPlaceholder: true))
        }
        
        self.sampleHandler.updateData(data.samples)
        self.sampledByHandler.updateData(data.sampled_by)
        
        self.sampledByTableView.reloadData()
        self.sampleTableView.reloadData()

        
    }
    
    func addToQueue(_ song: Song, completion: @escaping (Bool) -> ()) {
        spotify.getFirstTrackMatch(track: song.track, artist: song.artist) { result in
            guard let result = result else {
                completion(false)
                return
            }
            self.spotify.addTrackToQueue(track: result) { sucess in
                completion(sucess)
            }
        }
    }
    
    private func togglePlaybackStateButton(isActive: Bool) {
        if !isActive {
            playbackStateButton.isHidden = true
            return
        }
        
        playbackStateButton.isHidden = false
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
        self.getAndSetData()
    }
}

extension MainViewController {
    static func freshController(_ spotify: Spotify, _ popoverControllerRef: PopoverController) -> MainViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        guard let viewcontroller =
                storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("MainViewController")) as? MainViewController else {
            fatalError("Can't find view from storyboard")
        }
        
        viewcontroller.spotify = spotify
        viewcontroller.popoverControllerRef = popoverControllerRef
        
        return viewcontroller
    }
}
