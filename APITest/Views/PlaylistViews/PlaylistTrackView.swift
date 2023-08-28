//
//  PlayListTrackView.swift
//  APITest
//
//  Created by Krit Verma on 7/20/23.
//

import SwiftUI
import Combine
import SpotifyWebAPI

struct PlaylistTrackView: View {
    @EnvironmentObject var vm: SpotifyDriver

    @State private var alert: AlertItem? = nil
    
    @State private var loadTracksCancellable: AnyCancellable? = nil
    @State private var playAlbumCancellable: AnyCancellable? = nil
    
    @State private var isLoadingTracks = false
    @State private var couldntLoadTracks = false
    
    @State var allTracks: [Track] = []
    
    //var playlistItems: EnumeratedSequence<[PlaylistItem?]>

    let playlist: Playlist<PlaylistItemsReference>
    let image: Image
    
    init(playlist: Playlist<PlaylistItemsReference>, image: Image) {
        self.playlist = playlist
        self.image = image
        
    }
    
    /// Used by the preview provider to provide sample data.
    fileprivate init(playlist: Playlist<PlaylistItemsReference>, image: Image, tracks: [Track]) {
        self.playlist = playlist
        self.image = image
        self._allTracks = State(initialValue: tracks)
    }

    /// The album and artist name; e.g., "Abbey Road - The Beatles".
    var playlistName: String {
        return playlist.name
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                albumImageWithPlayButton
                    .padding(30)
                Text(playlistName)
                    .font(.title)
                    .bold()
                    .padding(.horizontal)
                    .padding(.top, -10)
                Text("\(playlist.items.total) Tracks")
                    .foregroundColor(.secondary)
                    .font(.title2)
                    .padding(.vertical, 10)
                if allTracks.isEmpty {
                    Group {
                        if isLoadingTracks {
                            HStack {
                                ProgressView()
                                    .padding()
                                Text("Loading Tracks")
                                    .font(.title)
                                    .foregroundColor(.secondary)
                            }
                        }
                        else if couldntLoadTracks {
                            Text("Couldn't Load Tracks")
                                .font(.title)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                }
                else {
                    ForEach(
                        Array(allTracks.enumerated()),
                        id: \.offset
                    ) { track in
                        PLTrackCellView(
                            track: track.element,
                            playlist: playlist
                        )
                        Divider()
                    }
                }
            }
        }
        .navigationTitle("")
        .alert(item: $alert) { alert in
            Alert(title: alert.title, message: alert.message)
        }
        .onAppear(perform: loadTracks)
    }
    
    var albumImageWithPlayButton: some View {
        ZStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(20)
                .shadow(radius: 20)
            Button(action: playPlaylist, label: {
                Image(systemName: "play.circle")
                    .resizable()
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
                    .frame(width: 100, height: 100)
            })
            .buttonStyle(.borderless)
        }
    }
    
    /// Loads the album tracks.
    func loadTracks() {
        
        // Don't try to load any tracks if we're in preview mode
        
        loadTracksCancellable = self.vm.spotify.playlistItems(playlist.uri)
            .extendPagesConcurrently(self.vm.spotify)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    print("received completion:", completion)
                    switch completion {
                        case .finished:
                            // We've finished finding the duplicates; now we
                            // need to remove them if there are any.
                            self.isLoadingTracks = true
                        case .failure(let error):
                            print("couldn't check for duplicates:\n\(error)")
                            self.isLoadingTracks = false
                            print(error.localizedDescription)
                    }
                },
                receiveValue: self.receivePlaylistItemsPage(page:)
            )
            
//
//
//        guard let tracks = self.playlist.tracks else {
//            return
//        }
//
//        // the `album` already contains the first page of tracks, but we need to
//        // load additional pages if they exist. the `extendPages` method
//        // immediately republishes the page that was passed in and then requests
//        // additional pages.
//
//        self.isLoadingTracks = true
//        self.allTracks = []
//        self.loadTracksCancellable = self.spotify.api.extendPages(tracks)
//            .map(\.items)
//            .receive(on: RunLoop.main)
//            .sink(
//                receiveCompletion: { completion in
//                    self.isLoadingTracks = false
//                    switch completion {
//                        case .finished:
//                            self.couldntLoadTracks = false
//                        case .failure(let error):
//                            self.couldntLoadTracks = true
//                            self.alert = AlertItem(
//                                title: "Couldn't Load Tracks",
//                                message: error.localizedDescription
//                            )
//                    }
//                },
//                receiveValue: { tracks in
//                    self.allTracks.append(contentsOf: tracks)
//                }
//            )
        
    }
    
    func receivePlaylistItemsPage(page: PlaylistItems) {
        
        print("received page at offset \(page.offset)")
        
        let playlistItems = page.items
            .map(\.item)
            .enumerated()
        
        for playlistItem in playlistItems {

//            guard let playlistItem = playlistItem else {
//                continue
//            }
            
            // skip local tracks
            if case .track(let track) = playlistItem.element {
                if track.isLocal { continue }
                else {  allTracks.append(track) }
            }
        }

    }
    
    
    
    func playPlaylist() {
        let playlistURI = playlist.uri
           
        let playbackRequest = PlaybackRequest(
            context: .contextURI(playlistURI), offset: nil
        )
        print("playing playlist '\(playlist.name)'")
        self.playAlbumCancellable = vm.spotify
            .play(playbackRequest)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                print("Received play album completion: \(completion)")
                if case .failure(let error) = completion {
                    self.alert = AlertItem(
                        title: "Couldn't Play Album",
                        message: error.localizedDescription
                    )
                }
            })
    }
}

struct PlaylistTrackView_Previews: PreviewProvider {
    static let spotify = SpotifyDriver()
    static var previews: some View {
        PlaylistTrackView(playlist: Playlist.lucyInTheSkyWithDiamonds, image: Image("EmptyTrack"))
            .environmentObject(spotify)
    }
}
