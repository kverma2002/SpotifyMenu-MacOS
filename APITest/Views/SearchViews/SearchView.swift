//
//  SearchView.swift
//  APITest
//
//  Created by Krit Verma on 7/24/23.
//

import SwiftUI
import SpotifyWebAPI
import Combine

struct SearchView: View {
    
    @State var search = ""
    
    @EnvironmentObject var vm: SpotifyDriver

    @State private var playlists: [Playlist<PlaylistItemsReference>] = []
    @State private var cancellables: AnyCancellable? = nil
    @State private var trackcancellables: AnyCancellable? = nil
    @State private var playlistcancellables: AnyCancellable? = nil
    
    
    
    
    @State private var albums: [Album] = []
    @State private var alert: AlertItem? = nil
    @State var allTracks: [Track] = []
    
//    fileprivate init(sampleAlbums: [Album]) {
//        self.albums = sampleAlbums
//    }
    
    let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 200))
    ]
    let rows = [
        GridItem(.adaptive(minimum: 100,maximum: 200))
    ]

    
    
    var body: some View {
            VStack {
                HStack {
                    TextField("Seach Playlists, Albums and Songs", text: $search)
                    
                    Button(action: getSearch, label: {
                        HStack {
                            Text("Search")
                        }
                    })
                    .keyboardShortcut(.return)
                }
                List {
                    Group {
                        Text("Songs - \(allTracks.count)")
                        
                            
                        ForEach(
                            Array(allTracks.enumerated()),
                            id: \.offset)
                        { track in
                           QueueGridItemView2(
                               index: track.offset,
                               track: track.element
                           )
                           Divider()
                       }
                    
                       
                       
                    
                    Spacer(minLength: 10)
                        
                        Text("Albums - \(albums.count)")
                            
                                ForEach(albums, id: \.id) { album in
                                    AlbumGridItemView(album: album)
                                }

                            
                        Spacer(minLength: 10)
                            Text("Playlists - \(playlists.count)")
                       
                            // WARNING: do not use `\.self` for the id. This is
                            // extremely expensive and causes lag when scrolling
                            // because the hash of the entire album instance, which
                            // is very large, must be calculated.
                            ForEach(playlists, id: \.uri) { playlist in
                                PlaylistSingleGridView(spotify: vm, playlist: playlist)
                            }
                            
                            
                        
                        
                    
                }
                
                
//
//                    List{
//                        // WARNING: do not use `\.self` for the id. This is
//                        // extremely expensive and causes lag when scrolling
//                        // because the hash of the entire album instance, which
//                        // is very large, must be calculated.
//                        ForEach(albums, id: \.id) { album in
//                            AlbumGridItemView(album: album)
//                        }
//                        .horizontalRadioGroupLayout()
//                    }
                    
                    
                }

            
        }

        
    }
    
    func getSearch() {
        self.allTracks = []
        self.trackcancellables = self.vm.spotify.search(query: search, categories: [.track],limit: 5)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                        case .finished:
                            //self.couldntLoadTracks = false
                            print("Greate Track Search")
                        case .failure(let error):
                            //self.couldntLoadTracks = true
                            print(error.localizedDescription)
                    }
                },
                receiveValue: { searchTracks in
                    guard let x = searchTracks.tracks else {return}
                    allTracks.append(contentsOf: x.items)
                }
            )
        self.albums = []
        self.cancellables = self.vm.spotify.search(query: search, categories: [.album],limit: 5)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                        case .finished:
                            //self.couldntLoadTracks = false
                            print("Greate Track Search")
                        case .failure(let error):
                            //self.couldntLoadTracks = true
                            print(error.localizedDescription)
                    }
                },
                receiveValue: { searchTracks in
                    guard let x = searchTracks.albums else {return}
                    albums.append(contentsOf: x.items)
                   
                })
        
        self.playlists = []
        self.playlistcancellables = self.vm.spotify.search(query: search, categories: [.playlist],limit: 5)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                        case .finished:
                            //self.couldntLoadTracks = false
                            print("Greate Track Search")
                        case .failure(let error):
                            //self.couldntLoadTracks = true
                            print(error.localizedDescription)
                    }
                },
                receiveValue: { searchTracks in
                    guard let x = searchTracks.playlists else {return}
                    playlists.append(contentsOf: x.items)

                }
                )
        
        
        
        
    }
    
//    func getFullAlbum(uri: String){
//        self.can = self.vm.spotify.album(uri)
//            .receive(on: RunLoop.main)
//            .sink(
//                receiveCompletion: { completion in
//                    switch completion {
//                        case .finished:
//                            //self.couldntLoadTracks = false
//                            print("Greate Track Search")
//                        case .failure(let error):
//                            //self.couldntLoadTracks = true
//                            print(error.localizedDescription)
//                            print("to")
//                    }
//                },
//                receiveValue: { album in
//                    self.albums.append(album)
//
//                })
//    }
}

struct SearchView_Previews: PreviewProvider {
    
    
    
    
    static var previews: some View {
        SearchView()
    }
}
