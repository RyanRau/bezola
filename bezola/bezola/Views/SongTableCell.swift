//
//  SongTableCellViewController.swift
//  bezola
//
//  Created by Ryan Rau on 12/8/21.
//

import Foundation
import Cocoa

class SongTableCell: NSView {
    
    @IBOutlet weak var track: ClickableTextField!
    @IBOutlet weak var artist: NSTextField!
    @IBOutlet weak var year: NSTextField!
    @IBOutlet weak var albumArt: NSImageView!
    
    @IBOutlet weak var addToQueueButton: NSButton!
    @IBOutlet weak var playButton: NSButton!
    
    @IBOutlet weak var queueStatus: NSImageView!
    
    var spotifyTrackUri: String? = nil
    var mainView: NSView?
    
    var onAddToQueue : (() -> ())? = nil
    
    init(isEmpty: Bool = false) {
        super.init(frame: NSRect.zero)
        _ = load(fromNIBNamed: "SongTableCell", isEmpty: isEmpty)
        super.layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadImage(url: String) {
        Helpers.fetchImage(url: url) { error, image in
            guard let image = image else { return }
            self.albumArt.image = image
        }
    }
    
    func configureSpotifyElements() {
        if spotifyTrackUri == nil {
            return
        }
    
        albumArt.addTrackingArea(Helpers.createTrackingArea(control: albumArt))
        track.onClickCallback = viewInSpotify
        
        addToQueueButton.isHidden = false
    }
    
    func load(fromNIBNamed nibName: String, isEmpty: Bool) -> Bool {
        var nibObjects: NSArray?
        let nibName = NSNib.Name(stringLiteral: nibName)
        
        let cellName = (isEmpty ? "EmptyCell" : "SongCell")
        
        if Bundle.main.loadNibNamed(nibName, owner: self, topLevelObjects: &nibObjects) {
            guard let nibObjects = nibObjects else { return false }
            
            guard let view = nibObjects.first(where: { obj in
                guard let obj = obj as? NSView else { return false }
                return (obj.identifier?.rawValue ?? "") == cellName
            }) as? NSView else { return false }
            
            mainView = view
            self.addSubview(mainView!)
            
            mainView?.translatesAutoresizingMaskIntoConstraints = false

            mainView?.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            mainView?.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            mainView?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            mainView?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            
            return true
            
        }
        
        return false
    }
    
    override func mouseEntered(with event: NSEvent) {
        if let owner = event.trackingArea?.owner as? NSControl {
            let id : String = owner.identifier!.rawValue

            switch id {
                case self.albumArt.identifier!.rawValue:
                    self.togglePlayButton(isActive: true)
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
                    self.togglePlayButton(isActive: false)
                default:
                    return
            }
        }
    }
    

    @IBAction func addToQueue(_ sender: Any) {
        if let onAddToQueue = self.onAddToQueue {
            addToQueueButton.isEnabled = false
            onAddToQueue()
        }
    }
    
    @IBAction func playTrack(_ sender: Any) {
        guard let uri = spotifyTrackUri else { return }
        SpotifyOSX.playTrack(uri)
    }
    
    func afterAddToQueue(sucess: Bool) {
        DispatchQueue.main.async { // Throws errors if not on main thread
            self.queueStatus.isHidden = false
            self.queueStatus.contentTintColor = (sucess ? NSColor.systemGreen : NSColor.systemRed)
            self.queueStatus.toolTip = (sucess ? "Sucessfully added to queue" : "Error adding to queue")
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                self.queueStatus.isHidden = true
//                self.addToQueueButton.isEnabled = true
//            }
        }
    }
    
    func togglePlayButton(isActive: Bool) {
        guard (spotifyTrackUri != nil) else { return }
        
        if !isActive {
            playButton.isHidden = true
            return
        }
        
        playButton.isHidden = false
    }
    
    func viewInSpotify() {
        guard let uri = spotifyTrackUri else { return }
        SpotifyOSX.openSpotifyTrack(uri: uri)
    }
}
