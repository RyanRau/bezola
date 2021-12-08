//
//  SpotifyListener.swift
//  bezola
//
//  Created by Ryan Rau on 12/8/21.
//

import Foundation

class SpotifyListener {
    
    private var listener: DistributedNotificationCenter?
    private let playbackChanged = NSNotification.Name(rawValue: "com.spotify.client.PlaybackStateChanged")
    
    var delegate: SpotifyListenerDelegate?
    
    public init() {
        start()
    }
    
    deinit {
        stop()
    }
    
}

extension SpotifyListener {
    
    public func start() {
        listener = DistributedNotificationCenter.default()
        listener?.addObserver(self,
                              selector: #selector(playbackStateChanged),
                              name: playbackChanged,
                              object: nil)
    }
    
    public func stop() {
        if listener != nil {
            listener?.removeObserver(self, name: playbackChanged, object: nil)
            listener = nil
        }
    }
    
    @objc public func playbackStateChanged(notification: NSNotification) {
        delegate?.playbackStateChanged()
    }
    
}

protocol SpotifyListenerDelegate {
    func playbackStateChanged()
}
