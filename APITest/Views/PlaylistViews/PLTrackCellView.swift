//
//  PLTrackCell.swift
//  APITest
//
//  Created by Krit Verma on 7/20/23.
//

import SwiftUI
import SpotifyWebAPI
import Combine

struct PLTrackCellView: View {
    @EnvironmentObject var vm: SpotifyDriver

    @State private var playTrackCancellable: AnyCancellable? = nil

    let track: Track
    let playlist: Playlist<PlaylistItemsReference>


    var body: some View {
        Button(action: playTrack, label: {
            Text("\(track.name) - \(track.artists?.first?.name ?? "")")
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .contentShape(Rectangle())
        })
        .buttonStyle(PlainButtonStyle())
    }
    
    func playTrack() {
        
        let alertTitle = "Couldn't play \(track.name)"

        guard let trackURI = track.uri else {
            
            return
        }
        
        let playbackRequest: PlaybackRequest
        
        let playlistURI = self.playlist.uri
        playbackRequest = PlaybackRequest(
                    context: .contextURI(playlistURI),
                    offset: .uri(trackURI)
                )
        
//        {
//            // Play the track in the context of its album. Always prefer
//            // providing a context; otherwise, the back and forwards buttons may
//            // not work.
//            playbackRequest = PlaybackRequest(
//                context: .contextURI(albumURI),
//                offset: .uri(trackURI)
//            )
//        }
//        else {
//            playbackRequest = PlaybackRequest(trackURI)
//        }

        self.playTrackCancellable = self.vm.spotify
            .play(playbackRequest)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("\(error)")
                }
            })
        
    }

}

struct PLTrackCell_Previews: PreviewProvider {
    
    static let playlist = Playlist.thisIsMFDoom
    static let tracks = Playlist.thisIsRadiohead.items
    
    
    static var previews: some View {
        PLTrackCellView( track: Track.comeTogether, playlist: playlist)
//        ScrollView {
//            LazyVStack(spacing: 0) {
//                ForEach(tracks, id: \.offset) { track in
//                    PLTrackCellView(
//
//                        track: track.element,
//                        playlist: playlist,
//                        alert: .constant(nil)
//                    )
//                    Divider()
//                }
//            }
//        }
    }
}
