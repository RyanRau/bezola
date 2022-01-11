//
//  SettingsViewController.swift
//  bezola
//
//  Created by Ryan Rau on 12/28/21.
//

import Cocoa
import Combine


class SettingsViewController: NSViewController {
    var spotify: Spotify = Spotify(isPlaceholder: true) // inits as placeholder class; avoids optional unwrapping
    
    @IBOutlet weak var currentUserImage: NSImageView!
    @IBOutlet weak var currentUserLabel: NSTextField!
    @IBOutlet weak var spotifyAuthButton: NSButton!
    
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        self.setSpotifyLabels(self.spotify.isAuthorized)
        self.setSpotifyProfileImage(self.spotify.isAuthorized)
        spotify.$isAuthorized.sink {
            if $0 != self.spotify.isAuthorized {
                self.setSpotifyLabels($0)
                self.setSpotifyProfileImage($0)
            }
        }.store(in: &cancellables)
        
        spotify.$currentUser.sink {
            self.setCurrentUserLabel($0?.displayName ?? "ERROR")
        }.store(in: &cancellables)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.view.window?.title = "Settings"
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        NSApp.setActivationPolicy(.accessory)
    }
    
    @IBAction func onSpotifyAuthButtonClick(_ sender: Any) {
        if spotify.isAuthorized {
            spotify.api.authorizationManager.deauthorize()
        }else{
            spotify.authorize()
        }
    }
}

extension SettingsViewController {
    func setSpotifyLabels(_ authStatus: Bool){
        if authStatus {
            setCurrentUserLabel(spotify.currentUser?.displayName ?? "ERROR")
            spotifyAuthButton.title = "Log out of Spotify"
        }else{
            currentUserLabel.stringValue = "Not logged in to Spotify"
            spotifyAuthButton.title = "Log in to Spotify"
        }
    }
    
    private func setCurrentUserLabel(_ displayName: String) {
        currentUserLabel.stringValue = "Logged in as: \(displayName)"
    }
    
    func setSpotifyProfileImage(_ authStatus: Bool) {
        if !authStatus {
           return setDefaultImage()
        }
        
        guard let imageURLString = self.spotify.currentUser?.images![0].url.absoluteString else { return setDefaultImage() }
        
        Helpers.fetchImage(url: imageURLString) { error, image in
            guard let image = image else { return }

            self.currentUserImage.image = image
        }
    }
    
    private func setDefaultImage() {
        self.currentUserImage.image = NSImage(
            systemSymbolName: "questionmark",
            accessibilityDescription: nil
        )
    }
}
