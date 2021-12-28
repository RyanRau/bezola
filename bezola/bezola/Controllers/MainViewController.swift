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
    
    @IBOutlet weak var currentUser: NSTextField!
    @IBOutlet weak var spotifyButton: NSButton!
    
    @IBOutlet weak var sampleTableView: NSTableView!
    @IBOutlet weak var sampledByTableView: NSTableView!
    
    var current: Song = Song()
    var sampleData: SampleData = SampleData()
    
    var sampleHandler: TableHandler = TableHandler()
    var sampledByHandler: TableHandler = TableHandler()
    
    var spotify: Spotify = Spotify(isPlaceholder: true) // inits as placeholder class; avoids optional unwrapping
    let spotifyListener = SpotifyListener()
    
    var spotifyAuthStatus = false

    var popoverControllerRef: PopoverController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        spotifyListener.delegate = self
        
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
    
    
    func configTables(){
        sampleTableView.headerView = nil
        sampledByTableView.headerView = nil
        
        self.sampleHandler.updateData(self.sampleData.samples)
        sampleTableView.delegate = self.sampleHandler
        sampleTableView.dataSource = self.sampleHandler
        
        self.sampledByHandler.updateData(self.sampleData.samples)
        sampledByTableView.delegate = self.sampledByHandler
        sampledByTableView.dataSource = self.sampledByHandler
    }
}

extension MainViewController {
    func getAndSetData(){
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
        WhoSampled.getSampleData(self.current.track, self.current.artist) { sampleData in
            self.sampleData = sampleData

            self.sampleHandler.updateData(self.sampleData.samples)
            self.sampledByHandler.updateData(self.sampleData.sampled_by)
            
            self.sampleTableView.reloadData()
            self.sampledByTableView.reloadData()
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
