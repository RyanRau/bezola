//
//  SpotifyListener.swift
//  bezola
//
//  Created by Ryan Rau on 12/6/21.
//

import Foundation
import Cocoa
import Combine
import KeychainAccess
import SpotifyWebAPI

final class Spotify: ObservableObject {
    private static let spotifyCredentials = Helpers.getSpotifyCredentials()
    private let authorizationManagerKey = "authorizationManager"
    private let keychain = Keychain(service: "com.ryanrau.bezola")
    private var isPlaceholder = false
    
    let loginCallbackURL = URL(string: "bezola://login")!
    let api = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowManager(
            clientId: spotifyCredentials.clientId,
            clientSecret: spotifyCredentials.clientSecret
        )
    )

    var cancellables: Set<AnyCancellable> = []
    
    @Published var isAuthorized = false
    @Published var currentUser: SpotifyUser? = nil
    
    init(isPlaceholder: Bool = false){
        if isPlaceholder { // Allows for MainViewController to init with non nil Spotify Class
            self.isPlaceholder = isPlaceholder
            return
        }
        
        self.api.authorizationManagerDidChange
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidChange)
            .store(in: &cancellables)
        
        self.api.authorizationManagerDidDeauthorize
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidDeauthorize)
            .store(in: &cancellables)
        
        
        if let authManagerData = keychain[data: self.authorizationManagerKey] {
            do {
                let authorizationManager = try JSONDecoder().decode(
                    AuthorizationCodeFlowManager.self,
                    from: authManagerData
                )
                
                self.api.authorizationManager = authorizationManager
            } catch {
                print("FAILED TO DECODE authorizationManager FROM KEYCHAIN:\n \(error)")
            }
        }
        else {
            print("NO AUTHORIZATION INFORMATION FOUND IN KEYCHAIN")
        }
    }
}

// SpotifyAPI Calls
extension Spotify {
    func retrieveCurrentUser(onlyIfNil: Bool = true) {
        if onlyIfNil && self.currentUser != nil {
            return
        }

        guard self.isAuthorized else { return }

        self.api.currentUserProfile()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("couldn't retrieve current user: \(error)")
                    }
                },
                receiveValue: { user in
                    self.currentUser = user
                }
            )
            .store(in: &cancellables)
    }
    
    func searchTrack(_ track: String, _ artist: String) {
        guard self.isAuthorized else { return }
    }
    
    func getTrack() {
        guard self.isAuthorized else { return }
        
        self.api.search(
            query: "Tcheguedie Ao Cubo",
            categories: [.track, .artist],
            market: "US"
        )
        .sink(
            receiveCompletion: { completion in
                print("completion:", completion, terminator: "\n\n\n")
            },
            receiveValue: { results in
                print("\nReceived results for search for 'The Beatles'")
                let tracks = results.tracks?.items ?? []
                print("found \(tracks.count) tracks:")
                print("------------------------")
                for track in tracks {
                    print(track)
//                    print("\(track.name) - \(track.album?.name ?? "nil")")
                }
                
                let albums = results.albums?.items ?? []
                print("\nfound \(albums.count) albums:")
                print("------------------------")
                for album in albums {
                    print("\(album.name)")
                }
                
            }
        )
        .store(in: &cancellables)
    }
}

// SpotifyAPI Authorization
extension Spotify {
    func authorize(){
        let authorizationURL = api.authorizationManager.makeAuthorizationURL(
           redirectURI: loginCallbackURL,
           showDialog: false,
           scopes: [
               .playlistModifyPrivate,
               .userModifyPlaybackState,
               .playlistReadCollaborative,
               .userReadPlaybackPosition
           ]
       )!
       NSWorkspace.shared.open(authorizationURL)
    }
    
    func authorizationManagerDidChange(){
        self.isAuthorized = self.api.authorizationManager.isAuthorized()
        self.retrieveCurrentUser()
        
        do {
            let authManagerData = try JSONEncoder().encode(
                self.api.authorizationManager
            )
            
            keychain[data: self.authorizationManagerKey] = authManagerData
        } catch {
            print("COULDN'T STORE authorizationManager IN KEYCHAIN: \(error)")
        }
        
        print("Spotify Authorization Status Changed: \(self.isAuthorized)")
    }
    
    func authorizationManagerDidDeauthorize() {
        self.isAuthorized = false
        
        do {
            try keychain.remove(self.authorizationManagerKey)
        } catch {
            print(
                "COULDN'T REMOVE authorizationManager FROM KEYCHAIN: \(error)"
            )
        }
        print("Spotify Deauthorized")
    }
    
    func onCallBack(_ url: URL){
        api.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url
        )
        .sink(receiveCompletion: { completion in
            switch completion {
                case .finished:
                    print("Spotify Authorized")
                case .failure(let error):
                    print("ERROR OCCURED DURING AUTHORIZATION: \(error)")
            }
        })
        .store(in: &cancellables)
    }
}
