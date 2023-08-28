//
//  PlaylistView.swift
//  APITest
//
//  Created by Krit Verma on 7/20/23.
//

import SwiftUI
import Combine
import SpotifyWebAPI

struct PlaylistView: View {
    @EnvironmentObject var vm: SpotifyDriver

    @State private var playlists: [Playlist<PlaylistItemsReference>] = []
    
    @State private var cancellables: Set<AnyCancellable> = []
    
    @State private var isLoadingPlaylists = false
    @State private var couldntLoadPlaylists = false
    
    @State private var alert: AlertItem? = nil

    init() { }
    
    /// Used only by the preview provider to provide sample data.
    fileprivate init(samplePlaylists: [Playlist<PlaylistItemsReference>]) {
        self._playlists = State(initialValue: samplePlaylists)
    }
    
    var body: some View {
        VStack {
            if playlists.isEmpty {
                if isLoadingPlaylists {
                    HStack {
                        ProgressView()
                            .padding()
                        Text("Loading Playlists")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                }
                else if couldntLoadPlaylists {
                    Text("Couldn't Load Playlists")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
                else {
                    Text("No Playlists Found")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
            }
            else {
                List {
                    ForEach(playlists, id: \.uri) { playlist in
                        PlaylistSingleGridView(spotify: vm, playlist: playlist)
                    }
                }
                .listStyle(PlainListStyle())
                .accessibility(identifier: "Playlists List View")
            }
        }
        .navigationTitle("Playlists")
        .toolbar {
            refreshButton
        }
        .alert(item: $alert) { alert in
            Alert(title: alert.title, message: alert.message)
        }
        .onAppear(perform: retrievePlaylists)
        
    }
    
    var refreshButton: some View {
        Button(action: retrievePlaylists) {
            Image(systemName: "arrow.clockwise")
                .font(.title)
                .scaleEffect(0.8)
        }
        .disabled(isLoadingPlaylists)
        
    }
    
    func retrievePlaylists() {
        
        // Don't try to load any playlists if we're in preview mode.
        
        self.isLoadingPlaylists = true
        self.playlists = []
        vm.spotify.currentUserPlaylists()
            // Gets all pages of playlists.
            .extendPages(vm.spotify)
            .receive(on: RunLoop.main)
            .collect()
            .sink(
                receiveCompletion: { completion in
                    self.isLoadingPlaylists = false
                    switch completion {
                        case .finished:
                            self.couldntLoadPlaylists = false
                        case .failure(let error):
                            self.couldntLoadPlaylists = true
                            self.alert = AlertItem(
                                title: "Couldn't Retrieve Playlists",
                                message: error.localizedDescription
                            )
                    }
                },
                // We will receive a value for each page of playlists. You could
                // use Combine's `collect()` operator to wait until all of the
                // pages have been retrieved.
                receiveValue: { playlistsPage in
                    for x in playlistsPage {
                        let playlists = x.items
                        self.playlists.append(contentsOf: playlists)
                    }
                    print("Playlists \(self.playlists.count)")
//                    let playlists = playlistsPage.items
//                    self.playlists.append(contentsOf: playlists)
                }
            )
            .store(in: &cancellables)

    }
}

struct PlaylistView_Previews: PreviewProvider {
    
    static let spotify = SpotifyDriver()
    
    
    static var previews: some View {
        PlaylistView()
            .environmentObject(spotify)
    }
}
