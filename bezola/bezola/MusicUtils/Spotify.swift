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
import SpotifyExampleContent

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
    
    init(isPlaceholder: Bool = false) {
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
    
    func getCurrentDevice(completion: @escaping (Device?) -> ()) {
        DispatchQueue.main.async() {
            guard self.isAuthorized else {
                completion(nil)
                return
            }
            
            self.api.availableDevices().sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("ERROR HASS OCCURED: \(error)")
                    }
                },
                receiveValue: { results in
                    for device in results {
                        if device.isActive{
                            completion(device)
                        }
                    }
                    completion(nil)
                }
            ).store(in: &self.cancellables)
        }
    }
    
    func addTrackToQueue(track: Track, sucess: @escaping (Bool) -> ()) {
        DispatchQueue.main.async() {
            guard self.isAuthorized else {
                sucess(false)
                return
            }
            
            self.api.addToQueue(track.uri! as SpotifyURIConvertible)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            print("ERROR HASS OCCURED: \(error)")
                            sucess(false)
                        }
                        sucess(true)
                    }
                ).store(in: &self.cancellables)
        }
    }
    
    func getFirstTrackMatch(track: String, artist: String, completion: @escaping (Track?) -> ()) {
        DispatchQueue.main.async() {
            guard self.isAuthorized else {
                completion(nil)
                return
            }
            
            self.api.search(
                query: "track:\(track) artist:\(artist)",
                categories: [.track],
                limit: 1
            ).sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("ERROR HASS OCCURED: \(error)")
                    }
                },
                receiveValue: { result in
                    guard let tracks = result.tracks else {
                        completion(nil)
                        return
                    }
                    
                    if tracks.items.isEmpty {
                        completion(nil)
                    }else {
                        completion(tracks.items[0])
                    }
                }
            ).store(in: &self.cancellables)
        }
    }

    func completeWhoSampledData(data: WhoSampledData, completion: @escaping (WhoSampledData) -> ()) {
        var completeData = data
        let g = DispatchGroup()
        
        for i in data.samples.indices {
            g.enter()
            self.getFirstTrackMatch(track: data.samples[i].track, artist: data.samples[i].artist) { result in
                completeData.samples[i].spotifyTrack = result
                g.leave()
            }
        }
        
        for i in data.sampled_by.indices {
            g.enter()
            self.getFirstTrackMatch(track: data.sampled_by[i].track, artist: data.sampled_by[i].artist) { result in
                completeData.sampled_by[i].spotifyTrack = result
                g.leave()
            }
        }
        
        g.notify(queue: .main) {
            completion(completeData)
        }
    }
}

// SpotifyAPI Authorization
extension Spotify {
    func authorize() {
        let authorizationURL = api.authorizationManager.makeAuthorizationURL(
           redirectURI: loginCallbackURL,
           showDialog: false,
           scopes: [
               .playlistModifyPrivate,
               .userModifyPlaybackState,
               .playlistReadCollaborative,
               .userReadPlaybackPosition,
               .userReadPlaybackState
           ]
       )!
       NSWorkspace.shared.open(authorizationURL)
    }
    
    func authorizationManagerDidChange() {
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
    
    func onCallBack(_ url: URL) {
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
