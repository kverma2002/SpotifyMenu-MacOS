//
//  Spot.swift
//  APITest
//
//  Created by Krit Verma on 6/27/23.
//

import Foundation
import SpotifyWebAPI
import WebKit
import Combine
import SwiftUI


final class SpotifyDriver: ObservableObject {
    
    let spotify = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowPKCEManager (
            clientId: "Your client id"
        )
    )
    //
    // All variables used for generating API login through spotify with
    //{CKE Key exchange
    
    private var codeVerifier = ""
    private var codeChallenge = ""
    private var state = ""
    private var authorizationURL: URL
    private var accessToken = ""
    //
    
    // Authorized is teh check so we can succesfully make api calls
    @Published var authrorized = false
    
    var cancellables: Set<AnyCancellable> = []
    @Published var currentUser: SpotifyUser? = nil
    @Published var isRetrievingTokens = false
    
    @Published var playing = true
    
    
    
    init() {
        self.codeVerifier = String.randomURLSafe(length: 128)
        self.codeChallenge = String.makeCodeChallenge(codeVerifier: codeVerifier)
        self.state = String.randomURLSafe(length: 128)
        self.authorizationURL = spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: URL(string: "redirect-url")!,
            codeChallenge: codeChallenge,
            state: state,
            scopes: [
                .userReadCurrentlyPlaying,
                .userModifyPlaybackState,
                .userReadPlaybackState,
                .userLibraryRead,
                .userLibraryModify,
                .playlistReadPrivate
            ]
        )!
        self.spotify.authorizationManagerDidChange
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidChange)
            .store(in: &cancellables)
    }
    
    func URLOpener() {
        NSWorkspace.shared.open(authorizationURL)
    }
    
    func PopulateQueue() {
        if (self.authrorized) {
           
        }
        
    }
    
    func URLAuthorizer(queryURL: String ) {
//        let cancellables: any RangeReplaceableCollection
            spotify.authorizationManager.requestAccessAndRefreshTokens(
                redirectURIWithQuery: URL(string: queryURL)!,
                // Must match the code verifier that was used to generate the
                // code challenge when creating the authorization URL.
                codeVerifier: codeVerifier,
                // Must match the value used when creating the authorization URL.
                state: state
            )
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        print("noice")
                    case .failure(let error):
                        if let authError = error as? SpotifyAuthorizationError, authError.accessWasDenied {
                            print("The user denied the authorization request")
                        }
                        else {
                            print("couldn't authorize application: \(error)")
                        }
                }
            })
            .store(in: &cancellables)
        
        //self.authorizationManagerDidChange()
//        self.authrorized = self.spotify.authorizationManager.isAuthorized()
//        print(self.authrorized)
//
//        if (self.authrorized) {
//
//            self.spotify.currentUserProfile()
//                .receive(on: RunLoop.main)
//                .sink(
//                    receiveCompletion: { completion in
//                        if case .failure(let error) = completion {
//                            print("couldn't retrieve current user: \(error)")
//                        }
//                    },
//                    receiveValue: { user in
//                        self.currentUser = user
//                    }
//                )
//                .store(in: &cancellables)
//
//        }
//
//        print(currentUser?.displayName)
//            print("successfully authorized")
//            self.authrorized = true
//            let range = queryURL.range(of: "/?code=")
//            guard let uB = range?.upperBound else {return}
//            self.accessToken = String(queryURL[uB...])
//            let range2 = self.accessToken.range(of: "&state=")
//            guard let lb = range2?.lowerBound else {return}
//            self.accessToken = String(self.accessToken[..<lb])
//            print(self.accessToken)
        
        }
    
    func authorizationManagerDidChange() {
        
        withAnimation(ContentView.animation) {
            // Update the @Published `isAuthorized` property. When set to
            // `true`, `LoginView` is dismissed, allowing the user to interact
            // with the rest of the app.
            self.authrorized = self.spotify.authorizationManager.isAuthorized()
        }
        
        print(
            "Spotify.authorizationManagerDidChange: isAuthorized:",
            self.authrorized
        )
        
        self.retrieveCurrentUser()
        self.getPlay()
    }
    
    func getPlay() {

        guard self.authrorized else { return }

        self.spotify.currentPlayback()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("couldn't retrieve current user: \(error)")
                    }
                },
                receiveValue: { user in
                    if user?.isPlaying ?? false {
                        self.playing = true
                    }
                    else {
                        self.playing = false
                    }
                }
            )
            .store(in: &cancellables)
        
        
        
    }
    
    func retrieveCurrentUser(onlyIfNil: Bool = true) {
        
        if onlyIfNil && self.currentUser != nil {
            return
        }

        guard self.authrorized else { return }

        self.spotify.currentUserProfile()
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

}
    
    



